from typing import List


class CloneEntry:

    def __init__(self, begin_line: int, end_line: int, content: List[str]):
        self.begin_line = begin_line
        self.end_line = end_line
        self.content = content

    @staticmethod
    def from_json(data):
        return CloneEntry(data['beginline'], data['endline'], data['content'])


class FileEntry:

    def __init__(self, file_name: str, entries: List[CloneEntry]):
        self.file_name = file_name
        self.entries = entries

    @staticmethod
    def from_json(data):
        return FileEntry(data['file'], [CloneEntry.from_json(j) for j in data['entries']])


class CloneClass:

    def __init__(self, class_identifier: int, files: List[FileEntry]):
        self.class_identifier = class_identifier
        self.files = files
        self.num_clones = self.count_clones()

    @staticmethod
    def from_json(data):
        return CloneClass(data['class'], [FileEntry.from_json(j) for j in data['files']])

    def count_clones(self):
        i = 0

        for file in self.files:
            i += len(file.entries)

        return i
