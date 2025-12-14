import XCTest
@testable import RSS_app

final class RSSParserTests: XCTestCase {
    func testParsesBasicRSS() throws {
        let xml = """
        <rss><channel>
            <item>
                <title>Example</title>
                <link>https://example.com</link>
                <pubDate>Mon, 02 Jan 2006 15:04:05 +0000</pubDate>
                <description>Sample</description>
            </item>
        </channel></rss>
        """
        let data = Data(xml.utf8)
        let parser = RSSParser()
        let items = parser.parse(data: data, watchId: UUID(), sourceName: "Test")
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.title, "Example")
        XCTAssertEqual(items.first?.summary, "Sample")
    }
}
