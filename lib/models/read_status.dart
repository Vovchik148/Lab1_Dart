enum ReadStatus {
  planned('У планах'),
  reading('Читаю'),
  done('Прочитано');

  const ReadStatus(this.label);

  final String label;
}
