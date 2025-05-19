export function splitAtLast(str: string, character: string): [string, string] {
  const idx = str.lastIndexOf(character);
  if (idx === -1) {
    return [str, ''];
  }
  return [str.slice(0, idx), str.slice(idx + 1)];
}