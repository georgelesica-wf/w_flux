library w_flux.src.payload;

class Payload<T> {
  final bool isLocal;
  final T value;

  Payload(this.value, this.isLocal);
}