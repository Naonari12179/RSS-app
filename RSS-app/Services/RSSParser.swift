import Foundation

final class RSSParser: NSObject, XMLParserDelegate {
    private var items: [FeedItem] = []
    private var currentItem: [String: String] = [:]
    private var currentElement: String?
    private var currentText = ""
    private var currentWatchId: UUID?
    private var sourceName: String = ""

    func parse(data: Data, watchId: UUID, sourceName: String) -> [FeedItem] {
        self.items = []
        self.currentWatchId = watchId
        self.sourceName = sourceName
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return items
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName.lowercased()
        if currentElement == "item" || currentElement == "entry" {
            currentItem = [:]
        }
        currentText = ""
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let lower = elementName.lowercased()
        if lower == "item" || lower == "entry" {
            finalizeItem()
        } else {
            currentItem[lower] = (currentItem[lower] ?? "") + currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        currentText = ""
        currentElement = nil
    }

    private func finalizeItem() {
        guard let watchId = currentWatchId,
              let linkString = currentItem["link"] ?? currentItem["id"],
              let url = URL(string: linkString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            currentItem = [:]
            return
        }
        let title = currentItem["title"] ?? "(No title)"
        let description = currentItem["description"] ?? currentItem["summary"]
        let published = parseDate(from: currentItem["pubdate"] ?? currentItem["updated"])
        let item = FeedItem(title: title, url: url, sourceName: sourceName, publishedAt: published, summary: description, watchId: watchId)
        items.append(item)
        currentItem = [:]
    }

    private func parseDate(from string: String?) -> Date? {
        guard let string else { return nil }
        let formats = [
            "E, dd MMM yyyy HH:mm:ss Z",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        ]
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: string) { return date }
        }
        return nil
    }
}
