// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProviderConfigEntityCollection on Isar {
  IsarCollection<ProviderConfigEntity> get providerConfigEntitys =>
      this.collection();
}

const ProviderConfigEntitySchema = CollectionSchema(
  name: r'ProviderConfigEntity',
  id: 1310296424029056685,
  properties: {
    r'apiType': PropertySchema(
      id: 0,
      name: r'apiType',
      type: IsarType.string,
    ),
    r'baseUrl': PropertySchema(
      id: 1,
      name: r'baseUrl',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'customHeadersJson': PropertySchema(
      id: 3,
      name: r'customHeadersJson',
      type: IsarType.string,
    ),
    r'enabled': PropertySchema(
      id: 4,
      name: r'enabled',
      type: IsarType.bool,
    ),
    r'name': PropertySchema(
      id: 5,
      name: r'name',
      type: IsarType.string,
    ),
    r'priority': PropertySchema(
      id: 6,
      name: r'priority',
      type: IsarType.long,
    ),
    r'providerId': PropertySchema(
      id: 7,
      name: r'providerId',
      type: IsarType.string,
    ),
    r'timeoutSeconds': PropertySchema(
      id: 8,
      name: r'timeoutSeconds',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 9,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _providerConfigEntityEstimateSize,
  serialize: _providerConfigEntitySerialize,
  deserialize: _providerConfigEntityDeserialize,
  deserializeProp: _providerConfigEntityDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'providerId': IndexSchema(
      id: -1675978104265523206,
      name: r'providerId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'providerId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _providerConfigEntityGetId,
  getLinks: _providerConfigEntityGetLinks,
  attach: _providerConfigEntityAttach,
  version: '3.1.0+1',
);

int _providerConfigEntityEstimateSize(
  ProviderConfigEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.apiType.length * 3;
  bytesCount += 3 + object.baseUrl.length * 3;
  bytesCount += 3 + object.customHeadersJson.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.providerId.length * 3;
  return bytesCount;
}

void _providerConfigEntitySerialize(
  ProviderConfigEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.apiType);
  writer.writeString(offsets[1], object.baseUrl);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.customHeadersJson);
  writer.writeBool(offsets[4], object.enabled);
  writer.writeString(offsets[5], object.name);
  writer.writeLong(offsets[6], object.priority);
  writer.writeString(offsets[7], object.providerId);
  writer.writeLong(offsets[8], object.timeoutSeconds);
  writer.writeDateTime(offsets[9], object.updatedAt);
}

ProviderConfigEntity _providerConfigEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProviderConfigEntity();
  object.apiType = reader.readString(offsets[0]);
  object.baseUrl = reader.readString(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.customHeadersJson = reader.readString(offsets[3]);
  object.enabled = reader.readBool(offsets[4]);
  object.isarId = id;
  object.name = reader.readString(offsets[5]);
  object.priority = reader.readLong(offsets[6]);
  object.providerId = reader.readString(offsets[7]);
  object.timeoutSeconds = reader.readLong(offsets[8]);
  object.updatedAt = reader.readDateTime(offsets[9]);
  return object;
}

P _providerConfigEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _providerConfigEntityGetId(ProviderConfigEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _providerConfigEntityGetLinks(
    ProviderConfigEntity object) {
  return [];
}

void _providerConfigEntityAttach(
    IsarCollection<dynamic> col, Id id, ProviderConfigEntity object) {
  object.isarId = id;
}

extension ProviderConfigEntityByIndex on IsarCollection<ProviderConfigEntity> {
  Future<ProviderConfigEntity?> getByProviderId(String providerId) {
    return getByIndex(r'providerId', [providerId]);
  }

  ProviderConfigEntity? getByProviderIdSync(String providerId) {
    return getByIndexSync(r'providerId', [providerId]);
  }

  Future<bool> deleteByProviderId(String providerId) {
    return deleteByIndex(r'providerId', [providerId]);
  }

  bool deleteByProviderIdSync(String providerId) {
    return deleteByIndexSync(r'providerId', [providerId]);
  }

  Future<List<ProviderConfigEntity?>> getAllByProviderId(
      List<String> providerIdValues) {
    final values = providerIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'providerId', values);
  }

  List<ProviderConfigEntity?> getAllByProviderIdSync(
      List<String> providerIdValues) {
    final values = providerIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'providerId', values);
  }

  Future<int> deleteAllByProviderId(List<String> providerIdValues) {
    final values = providerIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'providerId', values);
  }

  int deleteAllByProviderIdSync(List<String> providerIdValues) {
    final values = providerIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'providerId', values);
  }

  Future<Id> putByProviderId(ProviderConfigEntity object) {
    return putByIndex(r'providerId', object);
  }

  Id putByProviderIdSync(ProviderConfigEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'providerId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByProviderId(List<ProviderConfigEntity> objects) {
    return putAllByIndex(r'providerId', objects);
  }

  List<Id> putAllByProviderIdSync(List<ProviderConfigEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'providerId', objects, saveLinks: saveLinks);
  }
}

extension ProviderConfigEntityQueryWhereSort
    on QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QWhere> {
  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ProviderConfigEntityQueryWhere
    on QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QWhereClause> {
  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterWhereClause>
      providerIdEqualTo(String providerId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'providerId',
        value: [providerId],
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterWhereClause>
      providerIdNotEqualTo(String providerId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerId',
              lower: [],
              upper: [providerId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerId',
              lower: [providerId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerId',
              lower: [providerId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerId',
              lower: [],
              upper: [providerId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ProviderConfigEntityQueryFilter on QueryBuilder<ProviderConfigEntity,
    ProviderConfigEntity, QFilterCondition> {
  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> apiTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'apiType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> apiTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'apiType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> apiTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'apiType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> apiTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'apiType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> apiTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'apiType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> apiTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'apiType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
          QAfterFilterCondition>
      apiTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'apiType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
          QAfterFilterCondition>
      apiTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'apiType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> apiTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'apiType',
        value: '',
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> apiTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'apiType',
        value: '',
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> baseUrlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baseUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> baseUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'baseUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> baseUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'baseUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> baseUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'baseUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> baseUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'baseUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> baseUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'baseUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
          QAfterFilterCondition>
      baseUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'baseUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
          QAfterFilterCondition>
      baseUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'baseUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> baseUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baseUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> baseUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'baseUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> customHeadersJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customHeadersJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> customHeadersJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'customHeadersJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> customHeadersJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'customHeadersJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> customHeadersJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'customHeadersJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> customHeadersJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'customHeadersJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> customHeadersJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'customHeadersJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
          QAfterFilterCondition>
      customHeadersJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'customHeadersJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
          QAfterFilterCondition>
      customHeadersJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'customHeadersJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> customHeadersJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customHeadersJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> customHeadersJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'customHeadersJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> enabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enabled',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
          QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
          QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> priorityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> priorityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> priorityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> priorityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'priority',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> providerIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'providerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> providerIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'providerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> providerIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'providerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> providerIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'providerId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> providerIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'providerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> providerIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'providerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
          QAfterFilterCondition>
      providerIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'providerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
          QAfterFilterCondition>
      providerIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'providerId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> providerIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'providerId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> providerIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'providerId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> timeoutSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timeoutSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> timeoutSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timeoutSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> timeoutSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timeoutSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> timeoutSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timeoutSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity,
      QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ProviderConfigEntityQueryObject on QueryBuilder<ProviderConfigEntity,
    ProviderConfigEntity, QFilterCondition> {}

extension ProviderConfigEntityQueryLinks on QueryBuilder<ProviderConfigEntity,
    ProviderConfigEntity, QFilterCondition> {}

extension ProviderConfigEntityQuerySortBy
    on QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QSortBy> {
  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      sortByApiType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apiType', Sort.asc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      sortByApiTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apiType', Sort.desc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      sortByBaseUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseUrl', Sort.asc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      sortByBaseUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseUrl', Sort.desc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      sortByCustomHeadersJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customHeadersJson', Sort.asc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      sortByCustomHeadersJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customHeadersJson', Sort.desc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      sortByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      sortByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      sortByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      sortByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      sortByProviderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.asc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      sortByProviderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.desc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      sortByTimeoutSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeoutSeconds', Sort.asc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      sortByTimeoutSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeoutSeconds', Sort.desc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ProviderConfigEntityQuerySortThenBy
    on QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QSortThenBy> {
  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      thenByApiType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apiType', Sort.asc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      thenByApiTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apiType', Sort.desc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      thenByBaseUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseUrl', Sort.asc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      thenByBaseUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseUrl', Sort.desc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      thenByCustomHeadersJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customHeadersJson', Sort.asc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      thenByCustomHeadersJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customHeadersJson', Sort.desc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      thenByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      thenByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      thenByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      thenByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      thenByProviderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.asc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      thenByProviderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.desc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      thenByTimeoutSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeoutSeconds', Sort.asc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      thenByTimeoutSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeoutSeconds', Sort.desc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ProviderConfigEntityQueryWhereDistinct
    on QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QDistinct> {
  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QDistinct>
      distinctByApiType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'apiType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QDistinct>
      distinctByBaseUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'baseUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QDistinct>
      distinctByCustomHeadersJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customHeadersJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QDistinct>
      distinctByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enabled');
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QDistinct>
      distinctByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QDistinct>
      distinctByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priority');
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QDistinct>
      distinctByProviderId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'providerId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QDistinct>
      distinctByTimeoutSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timeoutSeconds');
    });
  }

  QueryBuilder<ProviderConfigEntity, ProviderConfigEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension ProviderConfigEntityQueryProperty on QueryBuilder<
    ProviderConfigEntity, ProviderConfigEntity, QQueryProperty> {
  QueryBuilder<ProviderConfigEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<ProviderConfigEntity, String, QQueryOperations>
      apiTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'apiType');
    });
  }

  QueryBuilder<ProviderConfigEntity, String, QQueryOperations>
      baseUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'baseUrl');
    });
  }

  QueryBuilder<ProviderConfigEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ProviderConfigEntity, String, QQueryOperations>
      customHeadersJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customHeadersJson');
    });
  }

  QueryBuilder<ProviderConfigEntity, bool, QQueryOperations> enabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enabled');
    });
  }

  QueryBuilder<ProviderConfigEntity, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<ProviderConfigEntity, int, QQueryOperations> priorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priority');
    });
  }

  QueryBuilder<ProviderConfigEntity, String, QQueryOperations>
      providerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'providerId');
    });
  }

  QueryBuilder<ProviderConfigEntity, int, QQueryOperations>
      timeoutSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timeoutSeconds');
    });
  }

  QueryBuilder<ProviderConfigEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProviderHealthEntityCollection on Isar {
  IsarCollection<ProviderHealthEntity> get providerHealthEntitys =>
      this.collection();
}

const ProviderHealthEntitySchema = CollectionSchema(
  name: r'ProviderHealthEntity',
  id: -5616758302669869835,
  properties: {
    r'apiVersion': PropertySchema(
      id: 0,
      name: r'apiVersion',
      type: IsarType.string,
    ),
    r'errorMessage': PropertySchema(
      id: 1,
      name: r'errorMessage',
      type: IsarType.string,
    ),
    r'lastCheckedAt': PropertySchema(
      id: 2,
      name: r'lastCheckedAt',
      type: IsarType.dateTime,
    ),
    r'pingMs': PropertySchema(
      id: 3,
      name: r'pingMs',
      type: IsarType.long,
    ),
    r'providerId': PropertySchema(
      id: 4,
      name: r'providerId',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 5,
      name: r'status',
      type: IsarType.byte,
      enumMap: _ProviderHealthEntitystatusEnumValueMap,
    )
  },
  estimateSize: _providerHealthEntityEstimateSize,
  serialize: _providerHealthEntitySerialize,
  deserialize: _providerHealthEntityDeserialize,
  deserializeProp: _providerHealthEntityDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'providerId': IndexSchema(
      id: -1675978104265523206,
      name: r'providerId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'providerId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _providerHealthEntityGetId,
  getLinks: _providerHealthEntityGetLinks,
  attach: _providerHealthEntityAttach,
  version: '3.1.0+1',
);

int _providerHealthEntityEstimateSize(
  ProviderHealthEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.apiVersion;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.errorMessage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.providerId.length * 3;
  return bytesCount;
}

void _providerHealthEntitySerialize(
  ProviderHealthEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.apiVersion);
  writer.writeString(offsets[1], object.errorMessage);
  writer.writeDateTime(offsets[2], object.lastCheckedAt);
  writer.writeLong(offsets[3], object.pingMs);
  writer.writeString(offsets[4], object.providerId);
  writer.writeByte(offsets[5], object.status.index);
}

ProviderHealthEntity _providerHealthEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProviderHealthEntity();
  object.apiVersion = reader.readStringOrNull(offsets[0]);
  object.errorMessage = reader.readStringOrNull(offsets[1]);
  object.isarId = id;
  object.lastCheckedAt = reader.readDateTime(offsets[2]);
  object.pingMs = reader.readLong(offsets[3]);
  object.providerId = reader.readString(offsets[4]);
  object.status = _ProviderHealthEntitystatusValueEnumMap[
          reader.readByteOrNull(offsets[5])] ??
      ProviderStatus.unknown;
  return object;
}

P _providerHealthEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (_ProviderHealthEntitystatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          ProviderStatus.unknown) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ProviderHealthEntitystatusEnumValueMap = {
  'unknown': 0,
  'online': 1,
  'offline': 2,
};
const _ProviderHealthEntitystatusValueEnumMap = {
  0: ProviderStatus.unknown,
  1: ProviderStatus.online,
  2: ProviderStatus.offline,
};

Id _providerHealthEntityGetId(ProviderHealthEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _providerHealthEntityGetLinks(
    ProviderHealthEntity object) {
  return [];
}

void _providerHealthEntityAttach(
    IsarCollection<dynamic> col, Id id, ProviderHealthEntity object) {
  object.isarId = id;
}

extension ProviderHealthEntityByIndex on IsarCollection<ProviderHealthEntity> {
  Future<ProviderHealthEntity?> getByProviderId(String providerId) {
    return getByIndex(r'providerId', [providerId]);
  }

  ProviderHealthEntity? getByProviderIdSync(String providerId) {
    return getByIndexSync(r'providerId', [providerId]);
  }

  Future<bool> deleteByProviderId(String providerId) {
    return deleteByIndex(r'providerId', [providerId]);
  }

  bool deleteByProviderIdSync(String providerId) {
    return deleteByIndexSync(r'providerId', [providerId]);
  }

  Future<List<ProviderHealthEntity?>> getAllByProviderId(
      List<String> providerIdValues) {
    final values = providerIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'providerId', values);
  }

  List<ProviderHealthEntity?> getAllByProviderIdSync(
      List<String> providerIdValues) {
    final values = providerIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'providerId', values);
  }

  Future<int> deleteAllByProviderId(List<String> providerIdValues) {
    final values = providerIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'providerId', values);
  }

  int deleteAllByProviderIdSync(List<String> providerIdValues) {
    final values = providerIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'providerId', values);
  }

  Future<Id> putByProviderId(ProviderHealthEntity object) {
    return putByIndex(r'providerId', object);
  }

  Id putByProviderIdSync(ProviderHealthEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'providerId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByProviderId(List<ProviderHealthEntity> objects) {
    return putAllByIndex(r'providerId', objects);
  }

  List<Id> putAllByProviderIdSync(List<ProviderHealthEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'providerId', objects, saveLinks: saveLinks);
  }
}

extension ProviderHealthEntityQueryWhereSort
    on QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QWhere> {
  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ProviderHealthEntityQueryWhere
    on QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QWhereClause> {
  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterWhereClause>
      providerIdEqualTo(String providerId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'providerId',
        value: [providerId],
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterWhereClause>
      providerIdNotEqualTo(String providerId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerId',
              lower: [],
              upper: [providerId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerId',
              lower: [providerId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerId',
              lower: [providerId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerId',
              lower: [],
              upper: [providerId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ProviderHealthEntityQueryFilter on QueryBuilder<ProviderHealthEntity,
    ProviderHealthEntity, QFilterCondition> {
  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> apiVersionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'apiVersion',
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> apiVersionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'apiVersion',
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> apiVersionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'apiVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> apiVersionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'apiVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> apiVersionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'apiVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> apiVersionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'apiVersion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> apiVersionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'apiVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> apiVersionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'apiVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
          QAfterFilterCondition>
      apiVersionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'apiVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
          QAfterFilterCondition>
      apiVersionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'apiVersion',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> apiVersionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'apiVersion',
        value: '',
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> apiVersionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'apiVersion',
        value: '',
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> errorMessageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'errorMessage',
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> errorMessageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'errorMessage',
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> errorMessageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> errorMessageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> errorMessageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> errorMessageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'errorMessage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> errorMessageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> errorMessageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
          QAfterFilterCondition>
      errorMessageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
          QAfterFilterCondition>
      errorMessageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'errorMessage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> errorMessageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> errorMessageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'errorMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> lastCheckedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastCheckedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> lastCheckedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastCheckedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> lastCheckedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastCheckedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> lastCheckedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastCheckedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> pingMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pingMs',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> pingMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pingMs',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> pingMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pingMs',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> pingMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pingMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> providerIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'providerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> providerIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'providerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> providerIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'providerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> providerIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'providerId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> providerIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'providerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> providerIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'providerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
          QAfterFilterCondition>
      providerIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'providerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
          QAfterFilterCondition>
      providerIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'providerId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> providerIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'providerId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> providerIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'providerId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> statusEqualTo(ProviderStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> statusGreaterThan(
    ProviderStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> statusLessThan(
    ProviderStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity,
      QAfterFilterCondition> statusBetween(
    ProviderStatus lower,
    ProviderStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ProviderHealthEntityQueryObject on QueryBuilder<ProviderHealthEntity,
    ProviderHealthEntity, QFilterCondition> {}

extension ProviderHealthEntityQueryLinks on QueryBuilder<ProviderHealthEntity,
    ProviderHealthEntity, QFilterCondition> {}

extension ProviderHealthEntityQuerySortBy
    on QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QSortBy> {
  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterSortBy>
      sortByApiVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apiVersion', Sort.asc);
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterSortBy>
      sortByApiVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apiVersion', Sort.desc);
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterSortBy>
      sortByErrorMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.asc);
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterSortBy>
      sortByErrorMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.desc);
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterSortBy>
      sortByLastCheckedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCheckedAt', Sort.asc);
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterSortBy>
      sortByLastCheckedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCheckedAt', Sort.desc);
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterSortBy>
      sortByPingMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pingMs', Sort.asc);
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterSortBy>
      sortByPingMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pingMs', Sort.desc);
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterSortBy>
      sortByProviderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.asc);
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterSortBy>
      sortByProviderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.desc);
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension ProviderHealthEntityQuerySortThenBy
    on QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QSortThenBy> {
  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterSortBy>
      thenByApiVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apiVersion', Sort.asc);
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterSortBy>
      thenByApiVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apiVersion', Sort.desc);
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterSortBy>
      thenByErrorMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.asc);
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterSortBy>
      thenByErrorMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.desc);
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterSortBy>
      thenByLastCheckedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCheckedAt', Sort.asc);
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterSortBy>
      thenByLastCheckedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCheckedAt', Sort.desc);
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterSortBy>
      thenByPingMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pingMs', Sort.asc);
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterSortBy>
      thenByPingMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pingMs', Sort.desc);
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterSortBy>
      thenByProviderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.asc);
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterSortBy>
      thenByProviderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.desc);
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension ProviderHealthEntityQueryWhereDistinct
    on QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QDistinct> {
  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QDistinct>
      distinctByApiVersion({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'apiVersion', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QDistinct>
      distinctByErrorMessage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'errorMessage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QDistinct>
      distinctByLastCheckedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastCheckedAt');
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QDistinct>
      distinctByPingMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pingMs');
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QDistinct>
      distinctByProviderId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'providerId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderHealthEntity, QDistinct>
      distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }
}

extension ProviderHealthEntityQueryProperty on QueryBuilder<
    ProviderHealthEntity, ProviderHealthEntity, QQueryProperty> {
  QueryBuilder<ProviderHealthEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<ProviderHealthEntity, String?, QQueryOperations>
      apiVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'apiVersion');
    });
  }

  QueryBuilder<ProviderHealthEntity, String?, QQueryOperations>
      errorMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'errorMessage');
    });
  }

  QueryBuilder<ProviderHealthEntity, DateTime, QQueryOperations>
      lastCheckedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastCheckedAt');
    });
  }

  QueryBuilder<ProviderHealthEntity, int, QQueryOperations> pingMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pingMs');
    });
  }

  QueryBuilder<ProviderHealthEntity, String, QQueryOperations>
      providerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'providerId');
    });
  }

  QueryBuilder<ProviderHealthEntity, ProviderStatus, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCachedPostEntityCollection on Isar {
  IsarCollection<CachedPostEntity> get cachedPostEntitys => this.collection();
}

const CachedPostEntitySchema = CollectionSchema(
  name: r'CachedPostEntity',
  id: -5170622708650675238,
  properties: {
    r'cacheKey': PropertySchema(
      id: 0,
      name: r'cacheKey',
      type: IsarType.string,
    ),
    r'cachedAt': PropertySchema(
      id: 1,
      name: r'cachedAt',
      type: IsarType.dateTime,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'fileType': PropertySchema(
      id: 3,
      name: r'fileType',
      type: IsarType.string,
    ),
    r'fileUrl': PropertySchema(
      id: 4,
      name: r'fileUrl',
      type: IsarType.string,
    ),
    r'height': PropertySchema(
      id: 5,
      name: r'height',
      type: IsarType.long,
    ),
    r'postId': PropertySchema(
      id: 6,
      name: r'postId',
      type: IsarType.string,
    ),
    r'previewUrl': PropertySchema(
      id: 7,
      name: r'previewUrl',
      type: IsarType.string,
    ),
    r'providerId': PropertySchema(
      id: 8,
      name: r'providerId',
      type: IsarType.string,
    ),
    r'providerName': PropertySchema(
      id: 9,
      name: r'providerName',
      type: IsarType.string,
    ),
    r'rating': PropertySchema(
      id: 10,
      name: r'rating',
      type: IsarType.string,
    ),
    r'sampleUrl': PropertySchema(
      id: 11,
      name: r'sampleUrl',
      type: IsarType.string,
    ),
    r'score': PropertySchema(
      id: 12,
      name: r'score',
      type: IsarType.long,
    ),
    r'source': PropertySchema(
      id: 13,
      name: r'source',
      type: IsarType.string,
    ),
    r'tagGroupsJson': PropertySchema(
      id: 14,
      name: r'tagGroupsJson',
      type: IsarType.string,
    ),
    r'tags': PropertySchema(
      id: 15,
      name: r'tags',
      type: IsarType.stringList,
    ),
    r'width': PropertySchema(
      id: 16,
      name: r'width',
      type: IsarType.long,
    )
  },
  estimateSize: _cachedPostEntityEstimateSize,
  serialize: _cachedPostEntitySerialize,
  deserialize: _cachedPostEntityDeserialize,
  deserializeProp: _cachedPostEntityDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'cacheKey': IndexSchema(
      id: 5885332021012296610,
      name: r'cacheKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'cacheKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'providerId_postId': IndexSchema(
      id: 711415917800973915,
      name: r'providerId_postId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'providerId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'postId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _cachedPostEntityGetId,
  getLinks: _cachedPostEntityGetLinks,
  attach: _cachedPostEntityAttach,
  version: '3.1.0+1',
);

int _cachedPostEntityEstimateSize(
  CachedPostEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.cacheKey.length * 3;
  bytesCount += 3 + object.fileType.length * 3;
  bytesCount += 3 + object.fileUrl.length * 3;
  bytesCount += 3 + object.postId.length * 3;
  bytesCount += 3 + object.previewUrl.length * 3;
  bytesCount += 3 + object.providerId.length * 3;
  bytesCount += 3 + object.providerName.length * 3;
  bytesCount += 3 + object.rating.length * 3;
  bytesCount += 3 + object.sampleUrl.length * 3;
  {
    final value = object.source;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.tagGroupsJson.length * 3;
  bytesCount += 3 + object.tags.length * 3;
  {
    for (var i = 0; i < object.tags.length; i++) {
      final value = object.tags[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _cachedPostEntitySerialize(
  CachedPostEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cacheKey);
  writer.writeDateTime(offsets[1], object.cachedAt);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.fileType);
  writer.writeString(offsets[4], object.fileUrl);
  writer.writeLong(offsets[5], object.height);
  writer.writeString(offsets[6], object.postId);
  writer.writeString(offsets[7], object.previewUrl);
  writer.writeString(offsets[8], object.providerId);
  writer.writeString(offsets[9], object.providerName);
  writer.writeString(offsets[10], object.rating);
  writer.writeString(offsets[11], object.sampleUrl);
  writer.writeLong(offsets[12], object.score);
  writer.writeString(offsets[13], object.source);
  writer.writeString(offsets[14], object.tagGroupsJson);
  writer.writeStringList(offsets[15], object.tags);
  writer.writeLong(offsets[16], object.width);
}

CachedPostEntity _cachedPostEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CachedPostEntity();
  object.cacheKey = reader.readString(offsets[0]);
  object.cachedAt = reader.readDateTime(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.fileType = reader.readString(offsets[3]);
  object.fileUrl = reader.readString(offsets[4]);
  object.height = reader.readLong(offsets[5]);
  object.isarId = id;
  object.postId = reader.readString(offsets[6]);
  object.previewUrl = reader.readString(offsets[7]);
  object.providerId = reader.readString(offsets[8]);
  object.providerName = reader.readString(offsets[9]);
  object.rating = reader.readString(offsets[10]);
  object.sampleUrl = reader.readString(offsets[11]);
  object.score = reader.readLong(offsets[12]);
  object.source = reader.readStringOrNull(offsets[13]);
  object.tagGroupsJson = reader.readString(offsets[14]);
  object.tags = reader.readStringList(offsets[15]) ?? [];
  object.width = reader.readLong(offsets[16]);
  return object;
}

P _cachedPostEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readStringList(offset) ?? []) as P;
    case 16:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _cachedPostEntityGetId(CachedPostEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _cachedPostEntityGetLinks(CachedPostEntity object) {
  return [];
}

void _cachedPostEntityAttach(
    IsarCollection<dynamic> col, Id id, CachedPostEntity object) {
  object.isarId = id;
}

extension CachedPostEntityByIndex on IsarCollection<CachedPostEntity> {
  Future<CachedPostEntity?> getByCacheKey(String cacheKey) {
    return getByIndex(r'cacheKey', [cacheKey]);
  }

  CachedPostEntity? getByCacheKeySync(String cacheKey) {
    return getByIndexSync(r'cacheKey', [cacheKey]);
  }

  Future<bool> deleteByCacheKey(String cacheKey) {
    return deleteByIndex(r'cacheKey', [cacheKey]);
  }

  bool deleteByCacheKeySync(String cacheKey) {
    return deleteByIndexSync(r'cacheKey', [cacheKey]);
  }

  Future<List<CachedPostEntity?>> getAllByCacheKey(
      List<String> cacheKeyValues) {
    final values = cacheKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'cacheKey', values);
  }

  List<CachedPostEntity?> getAllByCacheKeySync(List<String> cacheKeyValues) {
    final values = cacheKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'cacheKey', values);
  }

  Future<int> deleteAllByCacheKey(List<String> cacheKeyValues) {
    final values = cacheKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'cacheKey', values);
  }

  int deleteAllByCacheKeySync(List<String> cacheKeyValues) {
    final values = cacheKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'cacheKey', values);
  }

  Future<Id> putByCacheKey(CachedPostEntity object) {
    return putByIndex(r'cacheKey', object);
  }

  Id putByCacheKeySync(CachedPostEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'cacheKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCacheKey(List<CachedPostEntity> objects) {
    return putAllByIndex(r'cacheKey', objects);
  }

  List<Id> putAllByCacheKeySync(List<CachedPostEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'cacheKey', objects, saveLinks: saveLinks);
  }
}

extension CachedPostEntityQueryWhereSort
    on QueryBuilder<CachedPostEntity, CachedPostEntity, QWhere> {
  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CachedPostEntityQueryWhere
    on QueryBuilder<CachedPostEntity, CachedPostEntity, QWhereClause> {
  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterWhereClause>
      cacheKeyEqualTo(String cacheKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'cacheKey',
        value: [cacheKey],
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterWhereClause>
      cacheKeyNotEqualTo(String cacheKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cacheKey',
              lower: [],
              upper: [cacheKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cacheKey',
              lower: [cacheKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cacheKey',
              lower: [cacheKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cacheKey',
              lower: [],
              upper: [cacheKey],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterWhereClause>
      providerIdEqualToAnyPostId(String providerId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'providerId_postId',
        value: [providerId],
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterWhereClause>
      providerIdNotEqualToAnyPostId(String providerId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerId_postId',
              lower: [],
              upper: [providerId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerId_postId',
              lower: [providerId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerId_postId',
              lower: [providerId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerId_postId',
              lower: [],
              upper: [providerId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterWhereClause>
      providerIdPostIdEqualTo(String providerId, String postId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'providerId_postId',
        value: [providerId, postId],
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterWhereClause>
      providerIdEqualToPostIdNotEqualTo(String providerId, String postId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerId_postId',
              lower: [providerId],
              upper: [providerId, postId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerId_postId',
              lower: [providerId, postId],
              includeLower: false,
              upper: [providerId],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerId_postId',
              lower: [providerId, postId],
              includeLower: false,
              upper: [providerId],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerId_postId',
              lower: [providerId],
              upper: [providerId, postId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension CachedPostEntityQueryFilter
    on QueryBuilder<CachedPostEntity, CachedPostEntity, QFilterCondition> {
  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      cacheKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      cacheKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      cacheKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      cacheKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cacheKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      cacheKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      cacheKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      cacheKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      cacheKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cacheKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      cacheKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cacheKey',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      cacheKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cacheKey',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      cachedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cachedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      cachedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cachedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      cachedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cachedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      cachedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cachedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      fileTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      fileTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fileType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      fileTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fileType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      fileTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fileType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      fileTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fileType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      fileTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fileType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      fileTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fileType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      fileTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fileType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      fileTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileType',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      fileTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fileType',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      fileUrlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      fileUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fileUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      fileUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fileUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      fileUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fileUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      fileUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fileUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      fileUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fileUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      fileUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fileUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      fileUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fileUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      fileUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      fileUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fileUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      heightEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'height',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      heightGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'height',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      heightLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'height',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      heightBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'height',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      postIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'postId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      postIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'postId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      postIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'postId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      postIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'postId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      postIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'postId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      postIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'postId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      postIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'postId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      postIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'postId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      postIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'postId',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      postIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'postId',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      previewUrlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'previewUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      previewUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'previewUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      previewUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'previewUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      previewUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'previewUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      previewUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'previewUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      previewUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'previewUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      previewUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'previewUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      previewUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'previewUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      previewUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'previewUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      previewUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'previewUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      providerIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'providerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      providerIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'providerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      providerIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'providerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      providerIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'providerId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      providerIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'providerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      providerIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'providerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      providerIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'providerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      providerIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'providerId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      providerIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'providerId',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      providerIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'providerId',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      providerNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'providerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      providerNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'providerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      providerNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'providerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      providerNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'providerName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      providerNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'providerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      providerNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'providerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      providerNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'providerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      providerNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'providerName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      providerNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'providerName',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      providerNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'providerName',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      ratingEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rating',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      ratingGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rating',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      ratingLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rating',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      ratingBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rating',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      ratingStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rating',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      ratingEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rating',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      ratingContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rating',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      ratingMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rating',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      ratingIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rating',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      ratingIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rating',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      sampleUrlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sampleUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      sampleUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sampleUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      sampleUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sampleUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      sampleUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sampleUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      sampleUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sampleUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      sampleUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sampleUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      sampleUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sampleUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      sampleUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sampleUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      sampleUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sampleUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      sampleUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sampleUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      scoreEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'score',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      scoreGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'score',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      scoreLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'score',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      scoreBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'score',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      sourceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'source',
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      sourceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'source',
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      sourceEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      sourceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      sourceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      sourceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'source',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      sourceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      sourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      sourceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      sourceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'source',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      sourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      sourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      tagGroupsJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tagGroupsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      tagGroupsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tagGroupsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      tagGroupsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tagGroupsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      tagGroupsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tagGroupsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      tagGroupsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tagGroupsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      tagGroupsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tagGroupsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      tagGroupsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tagGroupsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      tagGroupsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tagGroupsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      tagGroupsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tagGroupsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      tagGroupsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tagGroupsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      tagsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      tagsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      tagsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      tagsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tags',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      tagsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      tagsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      tagsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      tagsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tags',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      tagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      tagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      tagsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      tagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      tagsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      tagsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      tagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      widthEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'width',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      widthGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'width',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      widthLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'width',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterFilterCondition>
      widthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'width',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CachedPostEntityQueryObject
    on QueryBuilder<CachedPostEntity, CachedPostEntity, QFilterCondition> {}

extension CachedPostEntityQueryLinks
    on QueryBuilder<CachedPostEntity, CachedPostEntity, QFilterCondition> {}

extension CachedPostEntityQuerySortBy
    on QueryBuilder<CachedPostEntity, CachedPostEntity, QSortBy> {
  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      sortByCacheKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      sortByCacheKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.desc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      sortByCachedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      sortByCachedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.desc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      sortByFileType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileType', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      sortByFileTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileType', Sort.desc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      sortByFileUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileUrl', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      sortByFileUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileUrl', Sort.desc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      sortByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      sortByHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.desc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      sortByPostId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postId', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      sortByPostIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postId', Sort.desc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      sortByPreviewUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previewUrl', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      sortByPreviewUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previewUrl', Sort.desc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      sortByProviderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      sortByProviderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.desc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      sortByProviderName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerName', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      sortByProviderNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerName', Sort.desc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      sortByRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      sortByRatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.desc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      sortBySampleUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleUrl', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      sortBySampleUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleUrl', Sort.desc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy> sortByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      sortByScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.desc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      sortByTagGroupsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tagGroupsJson', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      sortByTagGroupsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tagGroupsJson', Sort.desc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy> sortByWidth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'width', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      sortByWidthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'width', Sort.desc);
    });
  }
}

extension CachedPostEntityQuerySortThenBy
    on QueryBuilder<CachedPostEntity, CachedPostEntity, QSortThenBy> {
  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenByCacheKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenByCacheKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.desc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenByCachedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenByCachedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.desc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenByFileType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileType', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenByFileTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileType', Sort.desc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenByFileUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileUrl', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenByFileUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileUrl', Sort.desc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenByHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.desc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenByPostId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postId', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenByPostIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postId', Sort.desc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenByPreviewUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previewUrl', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenByPreviewUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previewUrl', Sort.desc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenByProviderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenByProviderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.desc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenByProviderName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerName', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenByProviderNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerName', Sort.desc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenByRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenByRatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.desc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenBySampleUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleUrl', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenBySampleUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleUrl', Sort.desc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy> thenByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenByScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.desc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenByTagGroupsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tagGroupsJson', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenByTagGroupsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tagGroupsJson', Sort.desc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy> thenByWidth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'width', Sort.asc);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QAfterSortBy>
      thenByWidthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'width', Sort.desc);
    });
  }
}

extension CachedPostEntityQueryWhereDistinct
    on QueryBuilder<CachedPostEntity, CachedPostEntity, QDistinct> {
  QueryBuilder<CachedPostEntity, CachedPostEntity, QDistinct>
      distinctByCacheKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cacheKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QDistinct>
      distinctByCachedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cachedAt');
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QDistinct>
      distinctByFileType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QDistinct> distinctByFileUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QDistinct>
      distinctByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'height');
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QDistinct> distinctByPostId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'postId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QDistinct>
      distinctByPreviewUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'previewUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QDistinct>
      distinctByProviderId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'providerId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QDistinct>
      distinctByProviderName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'providerName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QDistinct> distinctByRating(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rating', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QDistinct>
      distinctBySampleUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sampleUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QDistinct>
      distinctByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'score');
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QDistinct> distinctBySource(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'source', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QDistinct>
      distinctByTagGroupsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tagGroupsJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QDistinct> distinctByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tags');
    });
  }

  QueryBuilder<CachedPostEntity, CachedPostEntity, QDistinct>
      distinctByWidth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'width');
    });
  }
}

extension CachedPostEntityQueryProperty
    on QueryBuilder<CachedPostEntity, CachedPostEntity, QQueryProperty> {
  QueryBuilder<CachedPostEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<CachedPostEntity, String, QQueryOperations> cacheKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cacheKey');
    });
  }

  QueryBuilder<CachedPostEntity, DateTime, QQueryOperations>
      cachedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cachedAt');
    });
  }

  QueryBuilder<CachedPostEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<CachedPostEntity, String, QQueryOperations> fileTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileType');
    });
  }

  QueryBuilder<CachedPostEntity, String, QQueryOperations> fileUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileUrl');
    });
  }

  QueryBuilder<CachedPostEntity, int, QQueryOperations> heightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'height');
    });
  }

  QueryBuilder<CachedPostEntity, String, QQueryOperations> postIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'postId');
    });
  }

  QueryBuilder<CachedPostEntity, String, QQueryOperations>
      previewUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'previewUrl');
    });
  }

  QueryBuilder<CachedPostEntity, String, QQueryOperations>
      providerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'providerId');
    });
  }

  QueryBuilder<CachedPostEntity, String, QQueryOperations>
      providerNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'providerName');
    });
  }

  QueryBuilder<CachedPostEntity, String, QQueryOperations> ratingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rating');
    });
  }

  QueryBuilder<CachedPostEntity, String, QQueryOperations> sampleUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sampleUrl');
    });
  }

  QueryBuilder<CachedPostEntity, int, QQueryOperations> scoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'score');
    });
  }

  QueryBuilder<CachedPostEntity, String?, QQueryOperations> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'source');
    });
  }

  QueryBuilder<CachedPostEntity, String, QQueryOperations>
      tagGroupsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tagGroupsJson');
    });
  }

  QueryBuilder<CachedPostEntity, List<String>, QQueryOperations>
      tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tags');
    });
  }

  QueryBuilder<CachedPostEntity, int, QQueryOperations> widthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'width');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFavoriteEntityCollection on Isar {
  IsarCollection<FavoriteEntity> get favoriteEntitys => this.collection();
}

const FavoriteEntitySchema = CollectionSchema(
  name: r'FavoriteEntity',
  id: -2424802716597037588,
  properties: {
    r'favoriteId': PropertySchema(
      id: 0,
      name: r'favoriteId',
      type: IsarType.string,
    ),
    r'favoriteKey': PropertySchema(
      id: 1,
      name: r'favoriteKey',
      type: IsarType.string,
    ),
    r'postId': PropertySchema(
      id: 2,
      name: r'postId',
      type: IsarType.string,
    ),
    r'providerId': PropertySchema(
      id: 3,
      name: r'providerId',
      type: IsarType.string,
    ),
    r'savedAt': PropertySchema(
      id: 4,
      name: r'savedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _favoriteEntityEstimateSize,
  serialize: _favoriteEntitySerialize,
  deserialize: _favoriteEntityDeserialize,
  deserializeProp: _favoriteEntityDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'favoriteKey': IndexSchema(
      id: 2684096142477831931,
      name: r'favoriteKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'favoriteKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _favoriteEntityGetId,
  getLinks: _favoriteEntityGetLinks,
  attach: _favoriteEntityAttach,
  version: '3.1.0+1',
);

int _favoriteEntityEstimateSize(
  FavoriteEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.favoriteId.length * 3;
  bytesCount += 3 + object.favoriteKey.length * 3;
  bytesCount += 3 + object.postId.length * 3;
  bytesCount += 3 + object.providerId.length * 3;
  return bytesCount;
}

void _favoriteEntitySerialize(
  FavoriteEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.favoriteId);
  writer.writeString(offsets[1], object.favoriteKey);
  writer.writeString(offsets[2], object.postId);
  writer.writeString(offsets[3], object.providerId);
  writer.writeDateTime(offsets[4], object.savedAt);
}

FavoriteEntity _favoriteEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FavoriteEntity();
  object.favoriteId = reader.readString(offsets[0]);
  object.favoriteKey = reader.readString(offsets[1]);
  object.isarId = id;
  object.postId = reader.readString(offsets[2]);
  object.providerId = reader.readString(offsets[3]);
  object.savedAt = reader.readDateTime(offsets[4]);
  return object;
}

P _favoriteEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _favoriteEntityGetId(FavoriteEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _favoriteEntityGetLinks(FavoriteEntity object) {
  return [];
}

void _favoriteEntityAttach(
    IsarCollection<dynamic> col, Id id, FavoriteEntity object) {
  object.isarId = id;
}

extension FavoriteEntityByIndex on IsarCollection<FavoriteEntity> {
  Future<FavoriteEntity?> getByFavoriteKey(String favoriteKey) {
    return getByIndex(r'favoriteKey', [favoriteKey]);
  }

  FavoriteEntity? getByFavoriteKeySync(String favoriteKey) {
    return getByIndexSync(r'favoriteKey', [favoriteKey]);
  }

  Future<bool> deleteByFavoriteKey(String favoriteKey) {
    return deleteByIndex(r'favoriteKey', [favoriteKey]);
  }

  bool deleteByFavoriteKeySync(String favoriteKey) {
    return deleteByIndexSync(r'favoriteKey', [favoriteKey]);
  }

  Future<List<FavoriteEntity?>> getAllByFavoriteKey(
      List<String> favoriteKeyValues) {
    final values = favoriteKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'favoriteKey', values);
  }

  List<FavoriteEntity?> getAllByFavoriteKeySync(
      List<String> favoriteKeyValues) {
    final values = favoriteKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'favoriteKey', values);
  }

  Future<int> deleteAllByFavoriteKey(List<String> favoriteKeyValues) {
    final values = favoriteKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'favoriteKey', values);
  }

  int deleteAllByFavoriteKeySync(List<String> favoriteKeyValues) {
    final values = favoriteKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'favoriteKey', values);
  }

  Future<Id> putByFavoriteKey(FavoriteEntity object) {
    return putByIndex(r'favoriteKey', object);
  }

  Id putByFavoriteKeySync(FavoriteEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'favoriteKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByFavoriteKey(List<FavoriteEntity> objects) {
    return putAllByIndex(r'favoriteKey', objects);
  }

  List<Id> putAllByFavoriteKeySync(List<FavoriteEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'favoriteKey', objects, saveLinks: saveLinks);
  }
}

extension FavoriteEntityQueryWhereSort
    on QueryBuilder<FavoriteEntity, FavoriteEntity, QWhere> {
  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FavoriteEntityQueryWhere
    on QueryBuilder<FavoriteEntity, FavoriteEntity, QWhereClause> {
  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterWhereClause> isarIdEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterWhereClause>
      favoriteKeyEqualTo(String favoriteKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'favoriteKey',
        value: [favoriteKey],
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterWhereClause>
      favoriteKeyNotEqualTo(String favoriteKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'favoriteKey',
              lower: [],
              upper: [favoriteKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'favoriteKey',
              lower: [favoriteKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'favoriteKey',
              lower: [favoriteKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'favoriteKey',
              lower: [],
              upper: [favoriteKey],
              includeUpper: false,
            ));
      }
    });
  }
}

extension FavoriteEntityQueryFilter
    on QueryBuilder<FavoriteEntity, FavoriteEntity, QFilterCondition> {
  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      favoriteIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'favoriteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      favoriteIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'favoriteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      favoriteIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'favoriteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      favoriteIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'favoriteId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      favoriteIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'favoriteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      favoriteIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'favoriteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      favoriteIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'favoriteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      favoriteIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'favoriteId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      favoriteIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'favoriteId',
        value: '',
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      favoriteIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'favoriteId',
        value: '',
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      favoriteKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'favoriteKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      favoriteKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'favoriteKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      favoriteKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'favoriteKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      favoriteKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'favoriteKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      favoriteKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'favoriteKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      favoriteKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'favoriteKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      favoriteKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'favoriteKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      favoriteKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'favoriteKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      favoriteKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'favoriteKey',
        value: '',
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      favoriteKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'favoriteKey',
        value: '',
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      postIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'postId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      postIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'postId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      postIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'postId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      postIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'postId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      postIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'postId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      postIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'postId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      postIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'postId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      postIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'postId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      postIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'postId',
        value: '',
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      postIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'postId',
        value: '',
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      providerIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'providerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      providerIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'providerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      providerIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'providerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      providerIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'providerId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      providerIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'providerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      providerIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'providerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      providerIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'providerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      providerIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'providerId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      providerIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'providerId',
        value: '',
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      providerIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'providerId',
        value: '',
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      savedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'savedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      savedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'savedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      savedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'savedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
      savedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'savedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FavoriteEntityQueryObject
    on QueryBuilder<FavoriteEntity, FavoriteEntity, QFilterCondition> {}

extension FavoriteEntityQueryLinks
    on QueryBuilder<FavoriteEntity, FavoriteEntity, QFilterCondition> {}

extension FavoriteEntityQuerySortBy
    on QueryBuilder<FavoriteEntity, FavoriteEntity, QSortBy> {
  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy>
      sortByFavoriteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'favoriteId', Sort.asc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy>
      sortByFavoriteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'favoriteId', Sort.desc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy>
      sortByFavoriteKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'favoriteKey', Sort.asc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy>
      sortByFavoriteKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'favoriteKey', Sort.desc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy> sortByPostId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postId', Sort.asc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy>
      sortByPostIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postId', Sort.desc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy>
      sortByProviderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.asc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy>
      sortByProviderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.desc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy> sortBySavedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAt', Sort.asc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy>
      sortBySavedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAt', Sort.desc);
    });
  }
}

extension FavoriteEntityQuerySortThenBy
    on QueryBuilder<FavoriteEntity, FavoriteEntity, QSortThenBy> {
  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy>
      thenByFavoriteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'favoriteId', Sort.asc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy>
      thenByFavoriteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'favoriteId', Sort.desc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy>
      thenByFavoriteKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'favoriteKey', Sort.asc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy>
      thenByFavoriteKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'favoriteKey', Sort.desc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy> thenByPostId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postId', Sort.asc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy>
      thenByPostIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postId', Sort.desc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy>
      thenByProviderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.asc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy>
      thenByProviderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.desc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy> thenBySavedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAt', Sort.asc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy>
      thenBySavedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAt', Sort.desc);
    });
  }
}

extension FavoriteEntityQueryWhereDistinct
    on QueryBuilder<FavoriteEntity, FavoriteEntity, QDistinct> {
  QueryBuilder<FavoriteEntity, FavoriteEntity, QDistinct> distinctByFavoriteId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'favoriteId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QDistinct> distinctByFavoriteKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'favoriteKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QDistinct> distinctByPostId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'postId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QDistinct> distinctByProviderId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'providerId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QDistinct> distinctBySavedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'savedAt');
    });
  }
}

extension FavoriteEntityQueryProperty
    on QueryBuilder<FavoriteEntity, FavoriteEntity, QQueryProperty> {
  QueryBuilder<FavoriteEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<FavoriteEntity, String, QQueryOperations> favoriteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'favoriteId');
    });
  }

  QueryBuilder<FavoriteEntity, String, QQueryOperations> favoriteKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'favoriteKey');
    });
  }

  QueryBuilder<FavoriteEntity, String, QQueryOperations> postIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'postId');
    });
  }

  QueryBuilder<FavoriteEntity, String, QQueryOperations> providerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'providerId');
    });
  }

  QueryBuilder<FavoriteEntity, DateTime, QQueryOperations> savedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'savedAt');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCollectionEntityCollection on Isar {
  IsarCollection<CollectionEntity> get collectionEntitys => this.collection();
}

const CollectionEntitySchema = CollectionSchema(
  name: r'CollectionEntity',
  id: 1279651062103045025,
  properties: {
    r'collectionId': PropertySchema(
      id: 0,
      name: r'collectionId',
      type: IsarType.string,
    ),
    r'coverUrl': PropertySchema(
      id: 1,
      name: r'coverUrl',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'description': PropertySchema(
      id: 3,
      name: r'description',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 4,
      name: r'name',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 5,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _collectionEntityEstimateSize,
  serialize: _collectionEntitySerialize,
  deserialize: _collectionEntityDeserialize,
  deserializeProp: _collectionEntityDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'collectionId': IndexSchema(
      id: -7489395134515229581,
      name: r'collectionId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'collectionId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _collectionEntityGetId,
  getLinks: _collectionEntityGetLinks,
  attach: _collectionEntityAttach,
  version: '3.1.0+1',
);

int _collectionEntityEstimateSize(
  CollectionEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.collectionId.length * 3;
  {
    final value = object.coverUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _collectionEntitySerialize(
  CollectionEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.collectionId);
  writer.writeString(offsets[1], object.coverUrl);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.description);
  writer.writeString(offsets[4], object.name);
  writer.writeDateTime(offsets[5], object.updatedAt);
}

CollectionEntity _collectionEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CollectionEntity();
  object.collectionId = reader.readString(offsets[0]);
  object.coverUrl = reader.readStringOrNull(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.description = reader.readStringOrNull(offsets[3]);
  object.isarId = id;
  object.name = reader.readString(offsets[4]);
  object.updatedAt = reader.readDateTime(offsets[5]);
  return object;
}

P _collectionEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _collectionEntityGetId(CollectionEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _collectionEntityGetLinks(CollectionEntity object) {
  return [];
}

void _collectionEntityAttach(
    IsarCollection<dynamic> col, Id id, CollectionEntity object) {
  object.isarId = id;
}

extension CollectionEntityByIndex on IsarCollection<CollectionEntity> {
  Future<CollectionEntity?> getByCollectionId(String collectionId) {
    return getByIndex(r'collectionId', [collectionId]);
  }

  CollectionEntity? getByCollectionIdSync(String collectionId) {
    return getByIndexSync(r'collectionId', [collectionId]);
  }

  Future<bool> deleteByCollectionId(String collectionId) {
    return deleteByIndex(r'collectionId', [collectionId]);
  }

  bool deleteByCollectionIdSync(String collectionId) {
    return deleteByIndexSync(r'collectionId', [collectionId]);
  }

  Future<List<CollectionEntity?>> getAllByCollectionId(
      List<String> collectionIdValues) {
    final values = collectionIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'collectionId', values);
  }

  List<CollectionEntity?> getAllByCollectionIdSync(
      List<String> collectionIdValues) {
    final values = collectionIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'collectionId', values);
  }

  Future<int> deleteAllByCollectionId(List<String> collectionIdValues) {
    final values = collectionIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'collectionId', values);
  }

  int deleteAllByCollectionIdSync(List<String> collectionIdValues) {
    final values = collectionIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'collectionId', values);
  }

  Future<Id> putByCollectionId(CollectionEntity object) {
    return putByIndex(r'collectionId', object);
  }

  Id putByCollectionIdSync(CollectionEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'collectionId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCollectionId(List<CollectionEntity> objects) {
    return putAllByIndex(r'collectionId', objects);
  }

  List<Id> putAllByCollectionIdSync(List<CollectionEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'collectionId', objects, saveLinks: saveLinks);
  }
}

extension CollectionEntityQueryWhereSort
    on QueryBuilder<CollectionEntity, CollectionEntity, QWhere> {
  QueryBuilder<CollectionEntity, CollectionEntity, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CollectionEntityQueryWhere
    on QueryBuilder<CollectionEntity, CollectionEntity, QWhereClause> {
  QueryBuilder<CollectionEntity, CollectionEntity, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterWhereClause>
      collectionIdEqualTo(String collectionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'collectionId',
        value: [collectionId],
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterWhereClause>
      collectionIdNotEqualTo(String collectionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectionId',
              lower: [],
              upper: [collectionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectionId',
              lower: [collectionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectionId',
              lower: [collectionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectionId',
              lower: [],
              upper: [collectionId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension CollectionEntityQueryFilter
    on QueryBuilder<CollectionEntity, CollectionEntity, QFilterCondition> {
  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      collectionIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      collectionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'collectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      collectionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'collectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      collectionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'collectionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      collectionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'collectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      collectionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'collectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      collectionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'collectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      collectionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'collectionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      collectionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collectionId',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      collectionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'collectionId',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      coverUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'coverUrl',
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      coverUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'coverUrl',
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      coverUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coverUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      coverUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'coverUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      coverUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'coverUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      coverUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'coverUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      coverUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'coverUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      coverUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'coverUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      coverUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'coverUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      coverUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'coverUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      coverUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coverUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      coverUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'coverUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      descriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CollectionEntityQueryObject
    on QueryBuilder<CollectionEntity, CollectionEntity, QFilterCondition> {}

extension CollectionEntityQueryLinks
    on QueryBuilder<CollectionEntity, CollectionEntity, QFilterCondition> {}

extension CollectionEntityQuerySortBy
    on QueryBuilder<CollectionEntity, CollectionEntity, QSortBy> {
  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy>
      sortByCollectionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionId', Sort.asc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy>
      sortByCollectionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionId', Sort.desc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy>
      sortByCoverUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverUrl', Sort.asc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy>
      sortByCoverUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverUrl', Sort.desc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy>
      sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension CollectionEntityQuerySortThenBy
    on QueryBuilder<CollectionEntity, CollectionEntity, QSortThenBy> {
  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy>
      thenByCollectionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionId', Sort.asc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy>
      thenByCollectionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionId', Sort.desc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy>
      thenByCoverUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverUrl', Sort.asc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy>
      thenByCoverUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverUrl', Sort.desc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy>
      thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension CollectionEntityQueryWhereDistinct
    on QueryBuilder<CollectionEntity, CollectionEntity, QDistinct> {
  QueryBuilder<CollectionEntity, CollectionEntity, QDistinct>
      distinctByCollectionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'collectionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QDistinct>
      distinctByCoverUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'coverUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension CollectionEntityQueryProperty
    on QueryBuilder<CollectionEntity, CollectionEntity, QQueryProperty> {
  QueryBuilder<CollectionEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<CollectionEntity, String, QQueryOperations>
      collectionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'collectionId');
    });
  }

  QueryBuilder<CollectionEntity, String?, QQueryOperations> coverUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'coverUrl');
    });
  }

  QueryBuilder<CollectionEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<CollectionEntity, String?, QQueryOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<CollectionEntity, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<CollectionEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCollectionPostEntityCollection on Isar {
  IsarCollection<CollectionPostEntity> get collectionPostEntitys =>
      this.collection();
}

const CollectionPostEntitySchema = CollectionSchema(
  name: r'CollectionPostEntity',
  id: -5862710918906928688,
  properties: {
    r'addedAt': PropertySchema(
      id: 0,
      name: r'addedAt',
      type: IsarType.dateTime,
    ),
    r'collectionId': PropertySchema(
      id: 1,
      name: r'collectionId',
      type: IsarType.string,
    ),
    r'linkKey': PropertySchema(
      id: 2,
      name: r'linkKey',
      type: IsarType.string,
    ),
    r'postId': PropertySchema(
      id: 3,
      name: r'postId',
      type: IsarType.string,
    ),
    r'providerId': PropertySchema(
      id: 4,
      name: r'providerId',
      type: IsarType.string,
    )
  },
  estimateSize: _collectionPostEntityEstimateSize,
  serialize: _collectionPostEntitySerialize,
  deserialize: _collectionPostEntityDeserialize,
  deserializeProp: _collectionPostEntityDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'linkKey': IndexSchema(
      id: 7263477011456965770,
      name: r'linkKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'linkKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'collectionId': IndexSchema(
      id: -7489395134515229581,
      name: r'collectionId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'collectionId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _collectionPostEntityGetId,
  getLinks: _collectionPostEntityGetLinks,
  attach: _collectionPostEntityAttach,
  version: '3.1.0+1',
);

int _collectionPostEntityEstimateSize(
  CollectionPostEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.collectionId.length * 3;
  bytesCount += 3 + object.linkKey.length * 3;
  bytesCount += 3 + object.postId.length * 3;
  bytesCount += 3 + object.providerId.length * 3;
  return bytesCount;
}

void _collectionPostEntitySerialize(
  CollectionPostEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.addedAt);
  writer.writeString(offsets[1], object.collectionId);
  writer.writeString(offsets[2], object.linkKey);
  writer.writeString(offsets[3], object.postId);
  writer.writeString(offsets[4], object.providerId);
}

CollectionPostEntity _collectionPostEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CollectionPostEntity();
  object.addedAt = reader.readDateTime(offsets[0]);
  object.collectionId = reader.readString(offsets[1]);
  object.isarId = id;
  object.linkKey = reader.readString(offsets[2]);
  object.postId = reader.readString(offsets[3]);
  object.providerId = reader.readString(offsets[4]);
  return object;
}

P _collectionPostEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _collectionPostEntityGetId(CollectionPostEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _collectionPostEntityGetLinks(
    CollectionPostEntity object) {
  return [];
}

void _collectionPostEntityAttach(
    IsarCollection<dynamic> col, Id id, CollectionPostEntity object) {
  object.isarId = id;
}

extension CollectionPostEntityByIndex on IsarCollection<CollectionPostEntity> {
  Future<CollectionPostEntity?> getByLinkKey(String linkKey) {
    return getByIndex(r'linkKey', [linkKey]);
  }

  CollectionPostEntity? getByLinkKeySync(String linkKey) {
    return getByIndexSync(r'linkKey', [linkKey]);
  }

  Future<bool> deleteByLinkKey(String linkKey) {
    return deleteByIndex(r'linkKey', [linkKey]);
  }

  bool deleteByLinkKeySync(String linkKey) {
    return deleteByIndexSync(r'linkKey', [linkKey]);
  }

  Future<List<CollectionPostEntity?>> getAllByLinkKey(
      List<String> linkKeyValues) {
    final values = linkKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'linkKey', values);
  }

  List<CollectionPostEntity?> getAllByLinkKeySync(List<String> linkKeyValues) {
    final values = linkKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'linkKey', values);
  }

  Future<int> deleteAllByLinkKey(List<String> linkKeyValues) {
    final values = linkKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'linkKey', values);
  }

  int deleteAllByLinkKeySync(List<String> linkKeyValues) {
    final values = linkKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'linkKey', values);
  }

  Future<Id> putByLinkKey(CollectionPostEntity object) {
    return putByIndex(r'linkKey', object);
  }

  Id putByLinkKeySync(CollectionPostEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'linkKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByLinkKey(List<CollectionPostEntity> objects) {
    return putAllByIndex(r'linkKey', objects);
  }

  List<Id> putAllByLinkKeySync(List<CollectionPostEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'linkKey', objects, saveLinks: saveLinks);
  }
}

extension CollectionPostEntityQueryWhereSort
    on QueryBuilder<CollectionPostEntity, CollectionPostEntity, QWhere> {
  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CollectionPostEntityQueryWhere
    on QueryBuilder<CollectionPostEntity, CollectionPostEntity, QWhereClause> {
  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterWhereClause>
      linkKeyEqualTo(String linkKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'linkKey',
        value: [linkKey],
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterWhereClause>
      linkKeyNotEqualTo(String linkKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'linkKey',
              lower: [],
              upper: [linkKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'linkKey',
              lower: [linkKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'linkKey',
              lower: [linkKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'linkKey',
              lower: [],
              upper: [linkKey],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterWhereClause>
      collectionIdEqualTo(String collectionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'collectionId',
        value: [collectionId],
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterWhereClause>
      collectionIdNotEqualTo(String collectionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectionId',
              lower: [],
              upper: [collectionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectionId',
              lower: [collectionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectionId',
              lower: [collectionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectionId',
              lower: [],
              upper: [collectionId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension CollectionPostEntityQueryFilter on QueryBuilder<CollectionPostEntity,
    CollectionPostEntity, QFilterCondition> {
  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> addedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'addedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> addedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'addedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> addedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'addedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> addedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'addedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> collectionIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> collectionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'collectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> collectionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'collectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> collectionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'collectionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> collectionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'collectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> collectionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'collectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
          QAfterFilterCondition>
      collectionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'collectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
          QAfterFilterCondition>
      collectionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'collectionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> collectionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collectionId',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> collectionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'collectionId',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> linkKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> linkKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'linkKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> linkKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'linkKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> linkKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'linkKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> linkKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'linkKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> linkKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'linkKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
          QAfterFilterCondition>
      linkKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'linkKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
          QAfterFilterCondition>
      linkKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'linkKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> linkKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkKey',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> linkKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'linkKey',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> postIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'postId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> postIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'postId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> postIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'postId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> postIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'postId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> postIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'postId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> postIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'postId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
          QAfterFilterCondition>
      postIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'postId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
          QAfterFilterCondition>
      postIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'postId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> postIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'postId',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> postIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'postId',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> providerIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'providerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> providerIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'providerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> providerIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'providerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> providerIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'providerId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> providerIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'providerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> providerIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'providerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
          QAfterFilterCondition>
      providerIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'providerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
          QAfterFilterCondition>
      providerIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'providerId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> providerIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'providerId',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity,
      QAfterFilterCondition> providerIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'providerId',
        value: '',
      ));
    });
  }
}

extension CollectionPostEntityQueryObject on QueryBuilder<CollectionPostEntity,
    CollectionPostEntity, QFilterCondition> {}

extension CollectionPostEntityQueryLinks on QueryBuilder<CollectionPostEntity,
    CollectionPostEntity, QFilterCondition> {}

extension CollectionPostEntityQuerySortBy
    on QueryBuilder<CollectionPostEntity, CollectionPostEntity, QSortBy> {
  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterSortBy>
      sortByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.asc);
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterSortBy>
      sortByAddedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.desc);
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterSortBy>
      sortByCollectionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionId', Sort.asc);
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterSortBy>
      sortByCollectionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionId', Sort.desc);
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterSortBy>
      sortByLinkKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkKey', Sort.asc);
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterSortBy>
      sortByLinkKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkKey', Sort.desc);
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterSortBy>
      sortByPostId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postId', Sort.asc);
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterSortBy>
      sortByPostIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postId', Sort.desc);
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterSortBy>
      sortByProviderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.asc);
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterSortBy>
      sortByProviderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.desc);
    });
  }
}

extension CollectionPostEntityQuerySortThenBy
    on QueryBuilder<CollectionPostEntity, CollectionPostEntity, QSortThenBy> {
  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterSortBy>
      thenByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.asc);
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterSortBy>
      thenByAddedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.desc);
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterSortBy>
      thenByCollectionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionId', Sort.asc);
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterSortBy>
      thenByCollectionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionId', Sort.desc);
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterSortBy>
      thenByLinkKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkKey', Sort.asc);
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterSortBy>
      thenByLinkKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkKey', Sort.desc);
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterSortBy>
      thenByPostId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postId', Sort.asc);
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterSortBy>
      thenByPostIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postId', Sort.desc);
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterSortBy>
      thenByProviderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.asc);
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QAfterSortBy>
      thenByProviderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.desc);
    });
  }
}

extension CollectionPostEntityQueryWhereDistinct
    on QueryBuilder<CollectionPostEntity, CollectionPostEntity, QDistinct> {
  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QDistinct>
      distinctByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'addedAt');
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QDistinct>
      distinctByCollectionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'collectionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QDistinct>
      distinctByLinkKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linkKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QDistinct>
      distinctByPostId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'postId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CollectionPostEntity, CollectionPostEntity, QDistinct>
      distinctByProviderId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'providerId', caseSensitive: caseSensitive);
    });
  }
}

extension CollectionPostEntityQueryProperty on QueryBuilder<
    CollectionPostEntity, CollectionPostEntity, QQueryProperty> {
  QueryBuilder<CollectionPostEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<CollectionPostEntity, DateTime, QQueryOperations>
      addedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'addedAt');
    });
  }

  QueryBuilder<CollectionPostEntity, String, QQueryOperations>
      collectionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'collectionId');
    });
  }

  QueryBuilder<CollectionPostEntity, String, QQueryOperations>
      linkKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkKey');
    });
  }

  QueryBuilder<CollectionPostEntity, String, QQueryOperations>
      postIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'postId');
    });
  }

  QueryBuilder<CollectionPostEntity, String, QQueryOperations>
      providerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'providerId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSearchHistoryEntityCollection on Isar {
  IsarCollection<SearchHistoryEntity> get searchHistoryEntitys =>
      this.collection();
}

const SearchHistoryEntitySchema = CollectionSchema(
  name: r'SearchHistoryEntity',
  id: -7201285660364201334,
  properties: {
    r'historyId': PropertySchema(
      id: 0,
      name: r'historyId',
      type: IsarType.string,
    ),
    r'query': PropertySchema(
      id: 1,
      name: r'query',
      type: IsarType.string,
    ),
    r'resultCount': PropertySchema(
      id: 2,
      name: r'resultCount',
      type: IsarType.long,
    ),
    r'searchedAt': PropertySchema(
      id: 3,
      name: r'searchedAt',
      type: IsarType.dateTime,
    ),
    r'tags': PropertySchema(
      id: 4,
      name: r'tags',
      type: IsarType.stringList,
    )
  },
  estimateSize: _searchHistoryEntityEstimateSize,
  serialize: _searchHistoryEntitySerialize,
  deserialize: _searchHistoryEntityDeserialize,
  deserializeProp: _searchHistoryEntityDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'historyId': IndexSchema(
      id: -2299313901551835913,
      name: r'historyId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'historyId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _searchHistoryEntityGetId,
  getLinks: _searchHistoryEntityGetLinks,
  attach: _searchHistoryEntityAttach,
  version: '3.1.0+1',
);

int _searchHistoryEntityEstimateSize(
  SearchHistoryEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.historyId.length * 3;
  bytesCount += 3 + object.query.length * 3;
  bytesCount += 3 + object.tags.length * 3;
  {
    for (var i = 0; i < object.tags.length; i++) {
      final value = object.tags[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _searchHistoryEntitySerialize(
  SearchHistoryEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.historyId);
  writer.writeString(offsets[1], object.query);
  writer.writeLong(offsets[2], object.resultCount);
  writer.writeDateTime(offsets[3], object.searchedAt);
  writer.writeStringList(offsets[4], object.tags);
}

SearchHistoryEntity _searchHistoryEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SearchHistoryEntity();
  object.historyId = reader.readString(offsets[0]);
  object.isarId = id;
  object.query = reader.readString(offsets[1]);
  object.resultCount = reader.readLong(offsets[2]);
  object.searchedAt = reader.readDateTime(offsets[3]);
  object.tags = reader.readStringList(offsets[4]) ?? [];
  return object;
}

P _searchHistoryEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _searchHistoryEntityGetId(SearchHistoryEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _searchHistoryEntityGetLinks(
    SearchHistoryEntity object) {
  return [];
}

void _searchHistoryEntityAttach(
    IsarCollection<dynamic> col, Id id, SearchHistoryEntity object) {
  object.isarId = id;
}

extension SearchHistoryEntityByIndex on IsarCollection<SearchHistoryEntity> {
  Future<SearchHistoryEntity?> getByHistoryId(String historyId) {
    return getByIndex(r'historyId', [historyId]);
  }

  SearchHistoryEntity? getByHistoryIdSync(String historyId) {
    return getByIndexSync(r'historyId', [historyId]);
  }

  Future<bool> deleteByHistoryId(String historyId) {
    return deleteByIndex(r'historyId', [historyId]);
  }

  bool deleteByHistoryIdSync(String historyId) {
    return deleteByIndexSync(r'historyId', [historyId]);
  }

  Future<List<SearchHistoryEntity?>> getAllByHistoryId(
      List<String> historyIdValues) {
    final values = historyIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'historyId', values);
  }

  List<SearchHistoryEntity?> getAllByHistoryIdSync(
      List<String> historyIdValues) {
    final values = historyIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'historyId', values);
  }

  Future<int> deleteAllByHistoryId(List<String> historyIdValues) {
    final values = historyIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'historyId', values);
  }

  int deleteAllByHistoryIdSync(List<String> historyIdValues) {
    final values = historyIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'historyId', values);
  }

  Future<Id> putByHistoryId(SearchHistoryEntity object) {
    return putByIndex(r'historyId', object);
  }

  Id putByHistoryIdSync(SearchHistoryEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'historyId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByHistoryId(List<SearchHistoryEntity> objects) {
    return putAllByIndex(r'historyId', objects);
  }

  List<Id> putAllByHistoryIdSync(List<SearchHistoryEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'historyId', objects, saveLinks: saveLinks);
  }
}

extension SearchHistoryEntityQueryWhereSort
    on QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QWhere> {
  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SearchHistoryEntityQueryWhere
    on QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QWhereClause> {
  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterWhereClause>
      historyIdEqualTo(String historyId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'historyId',
        value: [historyId],
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterWhereClause>
      historyIdNotEqualTo(String historyId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'historyId',
              lower: [],
              upper: [historyId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'historyId',
              lower: [historyId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'historyId',
              lower: [historyId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'historyId',
              lower: [],
              upper: [historyId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension SearchHistoryEntityQueryFilter on QueryBuilder<SearchHistoryEntity,
    SearchHistoryEntity, QFilterCondition> {
  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      historyIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'historyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      historyIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'historyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      historyIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'historyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      historyIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'historyId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      historyIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'historyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      historyIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'historyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      historyIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'historyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      historyIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'historyId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      historyIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'historyId',
        value: '',
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      historyIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'historyId',
        value: '',
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      queryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'query',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      queryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'query',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      queryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'query',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      queryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'query',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      queryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'query',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      queryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'query',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      queryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'query',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      queryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'query',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      queryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'query',
        value: '',
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      queryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'query',
        value: '',
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      resultCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'resultCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      resultCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'resultCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      resultCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'resultCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      resultCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'resultCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      searchedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'searchedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      searchedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'searchedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      searchedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'searchedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      searchedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'searchedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      tagsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      tagsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      tagsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      tagsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tags',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      tagsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      tagsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      tagsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      tagsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tags',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      tagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      tagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      tagsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      tagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      tagsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      tagsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
      tagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension SearchHistoryEntityQueryObject on QueryBuilder<SearchHistoryEntity,
    SearchHistoryEntity, QFilterCondition> {}

extension SearchHistoryEntityQueryLinks on QueryBuilder<SearchHistoryEntity,
    SearchHistoryEntity, QFilterCondition> {}

extension SearchHistoryEntityQuerySortBy
    on QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QSortBy> {
  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
      sortByHistoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'historyId', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
      sortByHistoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'historyId', Sort.desc);
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
      sortByQuery() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'query', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
      sortByQueryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'query', Sort.desc);
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
      sortByResultCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resultCount', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
      sortByResultCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resultCount', Sort.desc);
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
      sortBySearchedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchedAt', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
      sortBySearchedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchedAt', Sort.desc);
    });
  }
}

extension SearchHistoryEntityQuerySortThenBy
    on QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QSortThenBy> {
  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
      thenByHistoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'historyId', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
      thenByHistoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'historyId', Sort.desc);
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
      thenByQuery() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'query', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
      thenByQueryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'query', Sort.desc);
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
      thenByResultCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resultCount', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
      thenByResultCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resultCount', Sort.desc);
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
      thenBySearchedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchedAt', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
      thenBySearchedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchedAt', Sort.desc);
    });
  }
}

extension SearchHistoryEntityQueryWhereDistinct
    on QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QDistinct> {
  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QDistinct>
      distinctByHistoryId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'historyId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QDistinct>
      distinctByQuery({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'query', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QDistinct>
      distinctByResultCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'resultCount');
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QDistinct>
      distinctBySearchedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'searchedAt');
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QDistinct>
      distinctByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tags');
    });
  }
}

extension SearchHistoryEntityQueryProperty
    on QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QQueryProperty> {
  QueryBuilder<SearchHistoryEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<SearchHistoryEntity, String, QQueryOperations>
      historyIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'historyId');
    });
  }

  QueryBuilder<SearchHistoryEntity, String, QQueryOperations> queryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'query');
    });
  }

  QueryBuilder<SearchHistoryEntity, int, QQueryOperations>
      resultCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'resultCount');
    });
  }

  QueryBuilder<SearchHistoryEntity, DateTime, QQueryOperations>
      searchedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'searchedAt');
    });
  }

  QueryBuilder<SearchHistoryEntity, List<String>, QQueryOperations>
      tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tags');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppSettingEntityCollection on Isar {
  IsarCollection<AppSettingEntity> get appSettingEntitys => this.collection();
}

const AppSettingEntitySchema = CollectionSchema(
  name: r'AppSettingEntity',
  id: -2817644754785178746,
  properties: {
    r'jsonValue': PropertySchema(
      id: 0,
      name: r'jsonValue',
      type: IsarType.string,
    ),
    r'key': PropertySchema(
      id: 1,
      name: r'key',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 2,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _appSettingEntityEstimateSize,
  serialize: _appSettingEntitySerialize,
  deserialize: _appSettingEntityDeserialize,
  deserializeProp: _appSettingEntityDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'key': IndexSchema(
      id: -4906094122524121629,
      name: r'key',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'key',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _appSettingEntityGetId,
  getLinks: _appSettingEntityGetLinks,
  attach: _appSettingEntityAttach,
  version: '3.1.0+1',
);

int _appSettingEntityEstimateSize(
  AppSettingEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.jsonValue.length * 3;
  bytesCount += 3 + object.key.length * 3;
  return bytesCount;
}

void _appSettingEntitySerialize(
  AppSettingEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.jsonValue);
  writer.writeString(offsets[1], object.key);
  writer.writeDateTime(offsets[2], object.updatedAt);
}

AppSettingEntity _appSettingEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppSettingEntity();
  object.isarId = id;
  object.jsonValue = reader.readString(offsets[0]);
  object.key = reader.readString(offsets[1]);
  object.updatedAt = reader.readDateTime(offsets[2]);
  return object;
}

P _appSettingEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _appSettingEntityGetId(AppSettingEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _appSettingEntityGetLinks(AppSettingEntity object) {
  return [];
}

void _appSettingEntityAttach(
    IsarCollection<dynamic> col, Id id, AppSettingEntity object) {
  object.isarId = id;
}

extension AppSettingEntityByIndex on IsarCollection<AppSettingEntity> {
  Future<AppSettingEntity?> getByKey(String key) {
    return getByIndex(r'key', [key]);
  }

  AppSettingEntity? getByKeySync(String key) {
    return getByIndexSync(r'key', [key]);
  }

  Future<bool> deleteByKey(String key) {
    return deleteByIndex(r'key', [key]);
  }

  bool deleteByKeySync(String key) {
    return deleteByIndexSync(r'key', [key]);
  }

  Future<List<AppSettingEntity?>> getAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndex(r'key', values);
  }

  List<AppSettingEntity?> getAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'key', values);
  }

  Future<int> deleteAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'key', values);
  }

  int deleteAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'key', values);
  }

  Future<Id> putByKey(AppSettingEntity object) {
    return putByIndex(r'key', object);
  }

  Id putByKeySync(AppSettingEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'key', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByKey(List<AppSettingEntity> objects) {
    return putAllByIndex(r'key', objects);
  }

  List<Id> putAllByKeySync(List<AppSettingEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'key', objects, saveLinks: saveLinks);
  }
}

extension AppSettingEntityQueryWhereSort
    on QueryBuilder<AppSettingEntity, AppSettingEntity, QWhere> {
  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppSettingEntityQueryWhere
    on QueryBuilder<AppSettingEntity, AppSettingEntity, QWhereClause> {
  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterWhereClause>
      keyEqualTo(String key) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'key',
        value: [key],
      ));
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterWhereClause>
      keyNotEqualTo(String key) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [],
              upper: [key],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [key],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [key],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [],
              upper: [key],
              includeUpper: false,
            ));
      }
    });
  }
}

extension AppSettingEntityQueryFilter
    on QueryBuilder<AppSettingEntity, AppSettingEntity, QFilterCondition> {
  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterFilterCondition>
      jsonValueEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'jsonValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterFilterCondition>
      jsonValueGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'jsonValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterFilterCondition>
      jsonValueLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'jsonValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterFilterCondition>
      jsonValueBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'jsonValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterFilterCondition>
      jsonValueStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'jsonValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterFilterCondition>
      jsonValueEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'jsonValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterFilterCondition>
      jsonValueContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'jsonValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterFilterCondition>
      jsonValueMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'jsonValue',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterFilterCondition>
      jsonValueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'jsonValue',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterFilterCondition>
      jsonValueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'jsonValue',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterFilterCondition>
      keyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterFilterCondition>
      keyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterFilterCondition>
      keyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterFilterCondition>
      keyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'key',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterFilterCondition>
      keyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterFilterCondition>
      keyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterFilterCondition>
      keyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterFilterCondition>
      keyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'key',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterFilterCondition>
      keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'key',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterFilterCondition>
      keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'key',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AppSettingEntityQueryObject
    on QueryBuilder<AppSettingEntity, AppSettingEntity, QFilterCondition> {}

extension AppSettingEntityQueryLinks
    on QueryBuilder<AppSettingEntity, AppSettingEntity, QFilterCondition> {}

extension AppSettingEntityQuerySortBy
    on QueryBuilder<AppSettingEntity, AppSettingEntity, QSortBy> {
  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterSortBy>
      sortByJsonValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jsonValue', Sort.asc);
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterSortBy>
      sortByJsonValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jsonValue', Sort.desc);
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterSortBy> sortByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterSortBy>
      sortByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AppSettingEntityQuerySortThenBy
    on QueryBuilder<AppSettingEntity, AppSettingEntity, QSortThenBy> {
  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterSortBy>
      thenByJsonValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jsonValue', Sort.asc);
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterSortBy>
      thenByJsonValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jsonValue', Sort.desc);
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterSortBy> thenByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterSortBy>
      thenByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AppSettingEntityQueryWhereDistinct
    on QueryBuilder<AppSettingEntity, AppSettingEntity, QDistinct> {
  QueryBuilder<AppSettingEntity, AppSettingEntity, QDistinct>
      distinctByJsonValue({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'jsonValue', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QDistinct> distinctByKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'key', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettingEntity, AppSettingEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension AppSettingEntityQueryProperty
    on QueryBuilder<AppSettingEntity, AppSettingEntity, QQueryProperty> {
  QueryBuilder<AppSettingEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<AppSettingEntity, String, QQueryOperations> jsonValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'jsonValue');
    });
  }

  QueryBuilder<AppSettingEntity, String, QQueryOperations> keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'key');
    });
  }

  QueryBuilder<AppSettingEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
