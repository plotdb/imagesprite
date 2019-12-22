require! <[fs path]>

recurse = (root, config = {}, list = [], relpath = '.') ->
  if !fs.stat-sync(path.join(root, relpath)).is-directory! =>
    if !config.rule.exec(relpath) => return
    list.push {root, path: relpath}
    return
  files = fs.readdir-sync path.join(root, relpath) .map -> path.join relpath, it
  for file in files => recurse root, config, list, file

files = (root, config) ->
  recurse root, config, list = []
  return list

module.exports = {files, recurse}
