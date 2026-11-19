/// Kind of instrument the app tracks. Shared by portfolio and market.
enum AssetType { currency, gold, silver, stock, fund }

/// Identity of a priced instrument, e.g. `(type: AssetType.gold,
/// code: 'GRAM')`. A record, so equality and hashing are structural.
typedef Instrument = ({AssetType type, String code});
