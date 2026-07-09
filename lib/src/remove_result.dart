/// What a writer's `remove()` did: stock files written back, generated
/// files deleted, and files left alone because they no longer carry this
/// package's marker (edited by hand or written by another tool).
typedef RemoveResult = ({
  List<String> restored,
  List<String> deleted,
  List<String> skipped,
});
