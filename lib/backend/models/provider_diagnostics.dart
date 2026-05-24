class ProviderDiagnostics {
  const ProviderDiagnostics({
    required this.providerId,
    required this.lastSearchAt,
    required this.lastResultCount,
    this.lastErrorMessage,
  });

  final String providerId;
  final DateTime lastSearchAt;
  final int lastResultCount;
  final String? lastErrorMessage;
}
