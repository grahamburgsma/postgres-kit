/// PostgreSQL specific `SQLUpdate`.
public struct PostgreSQLUpdate: SQLUpdate {

    /// See `SQLUpdate`.
    public typealias TableIdentifier = PostgreSQLTableIdentifier

    /// See `SQLUpdate`.
    public typealias Identifier = PostgreSQLIdentifier

    /// See `SQLUpdate`.
    public typealias Expression = PostgreSQLExpression

    /// Creates a new `PostgreSQLUpdate`.
    public static func update(_ table: PostgreSQLTableIdentifier) -> PostgreSQLUpdate {
        return .init(table: table, values: [], predicate: nil, returning: [])
    }

    /// See `SQLUpdate`.
    public var table: PostgreSQLTableIdentifier

    /// See `SQLUpdate`.
    public var values: [(PostgreSQLIdentifier, PostgreSQLExpression)]

    /// See `SQLUpdate`.
    public var predicate: PostgreSQLExpression?

    /// `RETURNING *`
    public var returning: [PostgreSQLSelectExpression]

    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        var sql: [String] = []
        sql.append("UPDATE")
        sql.append(table.serialize(&binds))
        sql.append("SET")
        sql.append(values.map { $0.0.serialize(&binds) + " = " + $0.1.serialize(&binds) }.joined(separator: ", "))
        if let predicate = self.predicate {
            sql.append("WHERE")
            sql.append(predicate.serialize(&binds))
        }
        if !returning.isEmpty {
            sql.append("RETURNING")
            sql.append(returning.serialize(&binds))
        }
        return sql.joined(separator: " ")
    }
}

extension SQLUpdateBuilder where Connectable.Connection.Query.Update == PostgreSQLUpdate {
    /// Adds a `RETURNING` expression to the update query.
    public func returning(_ exprs: PostgreSQLSelectExpression...) -> Self {
        update.returning += exprs
        return self
    }
}
