class SerializableField {
  final String? name;
  final bool serialize; // include to function fromJson
  final bool deserialize; // include to function toJson
  final bool nullable; // include to function toJson

  const SerializableField({
    this.name,
    this.serialize = true,
    this.deserialize = true,
    this.nullable = false,
  });
}
