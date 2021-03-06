from typing import Tuple

import imgui

from models import CloneEntry, FileEntry


class FileBuffer:

    def __init__(self, file_path):
        self.content = []
        self.read_file(file_path)
        self.min_line = 0
        self.max_line = len(self.content)

    def read_file(self, file_path: str):
        with open(file_path, 'r', encoding='utf-8') as file:
            self.content = file.readlines()

    def to_imgui(self, file_entry: FileEntry, padding: int):
        for entry in file_entry.entries:
            start, end = self.range_for_entry(entry, padding)

            for i in range(start, end + 1):

                if i >= self.max_line:
                    break

                text = self.content[i]

                in_range = i in range(entry.begin_line, entry.end_line + 1)

                if in_range:
                    imgui.push_style_color(imgui.COLOR_TEXT, 0.0, 1.0, 0.0)

                imgui.text("{0:03d} {1}".format(i, text))

                if in_range:
                    imgui.pop_style_color(1)

            if entry is not file_entry.entries[-1]:
                imgui.spacing()
                imgui.separator()
                imgui.spacing()

    def range_for_entry(self, entry: CloneEntry, padding: int) -> Tuple[int, int]:
        start = max(self.min_line, entry.begin_line - padding)
        end = min(self.max_line, entry.end_line + padding)
        return start, end
