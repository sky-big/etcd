# Raft 不可靠日志

## 数据结构定义

```
type unstable struct {
	// the incoming unstable snapshot, if any.
	// leader 发送过来的快照，该快照是指还没有写入可靠性存储里面
	snapshot *pb.Snapshot
	
	// all entries that have not yet been written to storage.
	// 还没有写入可靠性存储的所有 entries
	entries []pb.Entry
	
	// 是第一个不可靠日志的索引 index
	// 单独用一个变量来存储第一个不可靠日志的索引，为什么没有用 entries[0].Index？
	// 是因为很多时刻 entries 是空的，比如刚启动的时刻，所有的不可靠日志都全部写入了可靠性存储里面的时刻
	offset  uint64

	logger Logger
}
```

## 重要函数实现

### maybeFirstIndex

```
// 函数名比较迷惑人，实际该函数是返回 `最近快照到现在的第一个日志索引`
// 切不可把它当成第一个不可靠日志的索引
func (u *unstable) maybeFirstIndex() (uint64, bool) {
	if u.snapshot != nil {
		return u.snapshot.Metadata.Index + 1, true
	}
	return 0, false
}
```

### truncateAndAppend

```
// leader 或者 follower 往里面添加日志
// leader: 是获取到 client 的日志直接将日志往不可靠日志里面添加
// follower: 是收到 leader 发送消息通知复制日志后，将消息里面的日志往不可靠日志里面添加
// follower 添加日志的时候会出现覆盖之前的日志，出现新的 leader 会将 follower 里面的日志强制刷掉
// 强制刷掉的原因是老的 leader 将日志复制给 follower，但是消息还没有 commit，但是老 leader 很快挂掉，新的 leader 将自己的日志发送过来将 follower 该处额日志覆盖掉
func (u *unstable) truncateAndAppend(ents []pb.Entry) {
	after := ents[0].Index
	switch {
	// follower 正常接收到 leader 日志, 将日志直接 append 到后面
	case after == u.offset+uint64(len(u.entries)):
		// after is the next index in the u.entries
		// directly append
		u.entries = append(u.entries, ents...)
	// leader 不认可这些日志，直接将 follower 的日志全部覆盖掉
	case after <= u.offset:
		u.logger.Infof("replace the unstable entries from index %d", after)
		// The log is being truncated to before our current offset
		// portion, so set the offset and replace the entries
		u.offset = after
		u.entries = ents
	// 当 after 在 offset 之后但与 unstable 中部分日志重叠时，重叠部分和之后部分可能会有冲突，
	// 因此裁剪掉 unstable 的日志中在 after 及其之后的部分，并将给定日志追加到其后
	default:
		// truncate to after and copy to u.entries
		// then append
		u.logger.Infof("truncate the unstable entries before index %d", after)
		u.entries = append([]pb.Entry{}, u.slice(u.offset, after)...)
		u.entries = append(u.entries, ents...)
	}
}
```