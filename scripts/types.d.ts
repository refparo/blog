interface ObjectConstructor {
  fromEntries<V>(entries: [[string, V]]): { [key: string]: V }
  fromEntries<V>(entries: [[number, V]]): { [key: number]: V }
}
