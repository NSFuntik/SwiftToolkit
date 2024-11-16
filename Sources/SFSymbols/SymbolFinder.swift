//
//  SymbolFinder.swift
//  FlomniChatCore
//
//  Created by Dmitry Mikhaylov on 25.05.2024.
//

import DI
import Foundation
import NaturalLanguage

extension DI {
  public static let symbolFinder = Key<MLSymbolFinder>()
}

// MARK: - MLSymbolFinder

/// extension NSCache<NSString, NSString>: @unchecked Sendable {}
/// ### Основные функции:
/// 1. **Сохранение кэша на диск**: Метод `saveCacheToDisk` используется для сериализации эмбеддингов и сохранения их на диск.
/// 2. **Загрузка кэша с диска**: Метод `loadCacheFromDisk` используется для десериализации эмбеддингов при запуске приложения.
/// 3. **Инициализация эмбеддингов и BK-Tree**: Инициализация эмбеддингов и BK-Tree происходит только если загрузка кэша с диска не удалась.
/// 4. **Кодирование и декодирование**: Для сохранения и загрузки данных на диск используется `PropertyListEncoder` и `PropertyListDecoder`.
public final class MLSymbolFinder {
  /// Singleton instance
  public static let `default` = MLSymbolFinder()

  private static var cache = NSCache<NSString, NSString>()
  private lazy var symbolEmbeddings = [String: [Double]]()
  private lazy var bkTree = BKTree()
  private let cacheFileURL: URL

  private init() {
    // Определение пути к файлу кэша
    let fileManager = FileManager.default
    let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)

    self.cacheFileURL = urls[0].appendingPathComponent("symbolEmbeddingsCache.plist")

    // debugPrint("Инициализация MLSymbolFinder...")
    // Асинхронная инициализация эмбеддингов и BK-Tree для всех символов SFSymbol
    DispatchQueue.global(qos: .utility).async { Task { await self.initialize() } }
  }

  private func initialize() async {
    // Попытка загрузки кэша с диска
    if await !loadCacheFromDisk() {
      // Если загрузка кэша не удалась, инициализация эмбеддингов и BK-Tree
      DispatchQueue.global(qos: .utility).async {
        self.initializeEmbeddingsAndBKTree()
      }
    }
  }

  /// Инициализация эмбеддингов и BK-Tree...
  private func initializeEmbeddingsAndBKTree() {
    let allSymbols = SFSymbol.allCases.map { $0.rawValue.replacingOccurrences(of: ".", with: " ") }
    let group = DispatchGroup()

    // debugPrint("Инициализация эмбеддингов и BK-Tree...")
    // Асинхронная инициализация эмбеддингов и BK-Tree для всех символов

    for symbol in allSymbols {
      group.enter()
      DispatchQueue.global(qos: .utility).async {
        if let embedding = self.getSentenceEmbedding(for: symbol) {
          DispatchQueue.main.async {
            self.symbolEmbeddings[symbol] = embedding
            self.bkTree.add(word: symbol)
          }
        } else {
          DispatchQueue.main.async {
            self.bkTree.add(word: symbol)
          }
        }
        group.leave()
      }
    }

    group.notify(queue: .main) {
      //            // debugPrint("Инициализация всех эмбеддингов и BK-Tree завершена.")
      // Сохранение кэша на диск после инициализации
      self.saveCacheToDisk()
    }
  }

  private func saveCacheToDisk() {
    let encoder = PropertyListEncoder()
    do {
      let data = try encoder.encode(symbolEmbeddings)
      try data.write(to: cacheFileURL)
      // debugPrint("Кэш эмбеддингов сохранен на диск.")
    } catch {
      // debugPrint("Ошибка при сохранении кэша эмбеддингов на диск: \(error)")
    }
  }

  private func loadCacheFromDisk() async -> Bool {
    let decoder = PropertyListDecoder()
    let bundleURL = Bundle(for: Self.self).url(forResource: "symbolEmbeddingsCache", withExtension: "plist")

    do {
      var data: Data?
      if let bundleURL {
        data = try Data(contentsOf: bundleURL)
      } else {
        debugPrint("Error loading cache from bundle: symbolEmbeddingsCache.plist not found.")
        data = try Data(contentsOf: cacheFileURL)
      }
      guard let data = data else {
        debugPrint("Error catching data from symbolEmbeddingsCache.plist.")
        return false
      }
      // Decode data asynchronously
      symbolEmbeddings = try await withCheckedThrowingContinuation { continuation in
        DispatchQueue.global(qos: .utility).async {
          do {
            let decodedData = try decoder.decode([String: [Double]].self, from: data)
            continuation.resume(returning: decodedData)
          } catch {
            continuation.resume(throwing: error)
          }
        }
      }

      // Add words to bkTree on the main thread
      for symbol in symbolEmbeddings.keys {
        await MainActor.run {
          self.bkTree.add(word: symbol)
        }
      }

      debugPrint("Cache loaded successfully from disk.")
      return true
    } catch {
      debugPrint("Error loading cache from disk: \(error)")
      return false
    }
  }

  public static func findMostSimilarSymbol(to input: String) async -> SFSymbol? {
    let input = input.lowercased()
    // debugPrint("Поиск наиболее похожего символа для: \(input)")

    // Проверка на точное соответствие
    if let exactMatch = SFSymbol(rawValue: input) {
      // debugPrint("Точный символ: \(input)")
      return exactMatch
    }

    guard
      let result = MLSymbolFinder.default.findMostSimilarSymbolInternal(
        to: input.replacingOccurrences(of: ".", with: " ")
      )
    else {
      return nil
    }
    // debugPrint("охожий символ: \(result)")
    return SFSymbol(rawValue: result.replacingOccurrences(of: " ", with: "."))
  }

  private func findMostSimilarSymbolInternal(to input: String) -> String? {
    // debugPrint("Поиск наиболее похожего символа для: \(input)")

    if let cachedResult = MLSymbolFinder.cache.object(forKey: input as NSString) {
      // debugPrint("Результат найден в кеше: \(cachedResult)")
      return cachedResult as String
    }

    if let inputEmbedding = getSentenceEmbedding(for: input) {
      var mostSimilarSymbol: String?
      var highestSimilarity: Double = -1

      let queue = DispatchQueue.global(qos: .utility)
      let group = DispatchGroup()
      let lock = NSLock()

      for (symbol, embedding) in symbolEmbeddings {
        group.enter()
        queue.async {
          let similarity = self.cosineSimilarity(vectorA: inputEmbedding, vectorB: embedding)
          // debugPrint("Сходство между '\(input)' и '\(symbol)': \(similarity)")
          lock.lock()
          if similarity > highestSimilarity {
            highestSimilarity = similarity
            mostSimilarSymbol = symbol
          }
          lock.unlock()
          group.leave()
        }
      }
      group.wait()

      if let result = mostSimilarSymbol {
        // debugPrint("Наиболее похожий символ: \(result) с похожестью \(highestSimilarity)")
        MLSymbolFinder.cache.setObject(result as NSString, forKey: input as NSString)
        return result
      }
    }

    if let bkResult = bkTree.search(word: input, tolerance: 2).first {
      // debugPrint("Наиболее похожий символ найден в BK-Tree: \(bkResult)")
      MLSymbolFinder.cache.setObject(bkResult as NSString, forKey: input as NSString)
      return bkResult
    }
    // debugPrint("Не удалось найти похожий символ для: \(input)")
    return nil
  }

  private func getSentenceEmbedding(for text: String) -> [Double]? {
    let embedding = NLEmbedding.sentenceEmbedding(for: .english)
    if let vector = embedding?.vector(for: text) {
      return vector
    } else {
      // debugPrint("Эмбеддинг не найден для текста: \(text)");
      return nil
    }
  }

  private func tokenize(text: String) -> [String] {
    var tokens = [String]()
    let tokenizer = NLTokenizer(unit: .sentence)
    tokenizer.string = text
    tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
      tokens.append(String(text[tokenRange]))
      return true
    }
    return tokens
  }

  private func cosineSimilarity(vectorA: [Double], vectorB: [Double]) -> Double {
    let dotProduct = zip(vectorA, vectorB).map(*).reduce(0, +)
    let magnitudeA = sqrt(vectorA.map { $0 * $0 }.reduce(0, +))
    let magnitudeB = sqrt(vectorB.map { $0 * $0 }.reduce(0, +))
    return dotProduct / (magnitudeA * magnitudeB)
  }
}

// MARK: - BKTree

final class BKTree: Codable {
  private lazy var root: BKTreeNode? = nil

  func add(word: String) {
    guard let root else {
      self.root = BKTreeNode(word: word)
      return
    }
    addNode(root, word)
  }

  private func addNode(_ node: BKTreeNode, _ word: String) {
    DispatchQueue.global(qos: .utility).async {
      let distance = self.levenshtein(aStr: node.word, bStr: word)
      DispatchQueue.main.async {
        if let child = node.children[distance] {
          self.addNode(child, word)
        } else {
          node.children[distance] = BKTreeNode(word: word)
        }
      }
    }
  }

  func search(word: String, tolerance: Int) -> [String] {
    guard let root else {
      return []
    }
    var results: [String] = []
    searchNode(root, word, tolerance, &results)
    return results
  }

  private func searchNode(_ node: BKTreeNode, _ word: String, _ tolerance: Int, _ results: inout [String]) {
    let distance = levenshtein(aStr: node.word, bStr: word)
    if distance <= tolerance {
      results.append(node.word)
    }
    for i in (distance - tolerance)...(distance + tolerance) {
      if let child = node.children[i] {
        searchNode(child, word, tolerance, &results)
      }
    }
  }

  private func levenshtein(aStr: String, bStr: String) -> Int {
    let a = Array(aStr)
    let b = Array(bStr)
    let n = a.count
    let m = b.count

    var currentRow = [Int](0...m)
    var previousRow = [Int](repeating: 0, count: m + 1)

    for i in 1...n {
      previousRow = currentRow
      currentRow = [Int](repeating: 0, count: m + 1)
      currentRow[0] = i

      for j in 1...m {
        let cost = a[i - 1] == b[j - 1] ? 0 : 1
        currentRow[j] = min(
          previousRow[j] + 1,
          currentRow[j - 1] + 1,
          previousRow[j - 1] + cost
        )
      }
    }

    return currentRow[m]
  }

  final class BKTreeNode: Codable {
    var word: String
    var children: [Int: BKTreeNode] = [:]

    init(word: String) {
      self.word = word
    }
  }
}
