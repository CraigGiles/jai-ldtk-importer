
Header :: struct {
    file_type: string;
    app: string;
    doc: string;
    schema: string;
    app_author: string;
    app_version: string;
    url: string;
}

parse_header :: (object: *JSON_Object) -> Header {
    result: Header;

    header            := extract(object, "__header__").object;
    result.app_version = extract(header, "appVersion").str;
    result.app_author  = extract(header, "appAuthor").str;
    result.app         = extract(header, "app").str;
    result.doc         = extract(header, "doc").str;
    result.schema      = extract(header, "schema").str;
    result.file_type   = extract(header, "fileType").str;
    result.url         = extract(header, "url").str;

    return result;
}
