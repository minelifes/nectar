import 'dart:io';
import 'dart:typed_data';

class HttpsSecurityContext {
  final ByteData rootCACertificate, clientCertificate, privateKey;
  HttpsSecurityContext({
    required this.rootCACertificate,
    required this.clientCertificate,
    required this.privateKey,
  });

  SecurityContext context() {
    SecurityContext context = SecurityContext(withTrustedRoots: true);
    context.setTrustedCertificatesBytes(rootCACertificate.buffer.asUint8List());
    context.useCertificateChainBytes(clientCertificate.buffer.asUint8List());
    context.usePrivateKeyBytes(privateKey.buffer.asUint8List());
    return context;
  }
}
