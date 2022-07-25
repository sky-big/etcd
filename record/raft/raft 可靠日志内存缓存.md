# Raft 可靠日志内存缓存

## 数据结构定义

```
type MemoryStorage struct {
	// Protects access to all fields. Most methods of MemoryStorage are
	// run on the raft goroutine, but Append() is run on an application
	// goroutine.
	sync.Mutex

    // raft 协议里面节点需要持久化的信息
	hardState pb.HardState
	// 节点数据快照信息
	snapshot  pb.Snapshot
	// ents[i] has raft log position i+snapshot.Metadata.Index
	// ents[0] 为 dummy Entry, 该 Entry 是用来存储快照后第一个可靠 Entry 的索引 index
	// ents[1 -> len(ents)] 都是已经写入可靠存储的所有 Entry 在内存中的缓存
	ents []pb.Entry
}

// raft 协议里面节点需要持久化的信息
type HardState struct {
    //当前任期
	Term             uint64 `protobuf:"varint,1,opt,name=term" json:"term"`
	//投票给了谁
	Vote             uint64 `protobuf:"varint,2,opt,name=vote" json:"vote"`
	//已提交的位置
	Commit           uint64 `protobuf:"varint,3,opt,name=commit" json:"commit"`
	XXX_unrecognized []byte `json:"-"`
}
```

## 重要函数实现

### Append

```
// 将已经写入可靠存储的 Entry 在内存中 Append，方便后续数据查询处理
func (ms *MemoryStorage) Append(entries []pb.Entry) error {
	if len(entries) == 0 {
		return nil
	}

	ms.Lock()
	defer ms.Unlock()

	first := ms.firstIndex()
	last := entries[0].Index + uint64(len(entries)) - 1

	// shortcut if there is no new entry.
	if last < first {
		return nil
	}
	// truncate compacted entries
	if first > entries[0].Index {
		entries = entries[first-entries[0].Index:]
	}

	offset := entries[0].Index - ms.ents[0].Index
	switch {
	// append 的数据跟现有的数据有重叠，因此将 append 的数据覆盖老的数据
	case uint64(len(ms.ents)) > offset:
		ms.ents = append([]pb.Entry{}, ms.ents[:offset]...)
		ms.ents = append(ms.ents, entries...)
	// 理想情况，该情况是 append 的数据正好接在现有的数据后面
	case uint64(len(ms.ents)) == offset:
		ms.ents = append(ms.ents, entries...)
	// 异常情况，该情况是要 append 的数据和现有最大的数据中间还有空隙，导致认为数据丢失，进程直接 panic
	default:
		getLogger().Panicf("missing log entry [last: %d, append at: %d]",
			ms.lastIndex(), entries[0].Index)
	}
	return nil
}
```