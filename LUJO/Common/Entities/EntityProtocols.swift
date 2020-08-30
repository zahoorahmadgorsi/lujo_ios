protocol Searchable {
    static func search(matching pattern: String, completion: @escaping ([AnyObject]?, Error?) -> Void)
}
