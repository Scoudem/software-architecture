import glob
import json
from typing import List

import imgui
import os


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

    @staticmethod
    def from_json(data):
        return CloneClass(data['class'], [FileEntry.from_json(j) for j in data['files']])


def parse_clone_file(clone_file: str) -> CloneClass:
    with open(clone_file, 'r') as file:
        data = json.load(file)
        return CloneClass.from_json(data)


def setup() -> List[CloneClass]:
    clone_files = glob.glob(os.path.expanduser('~') + '/clones/*.txt')
    return [parse_clone_file(f) for f in clone_files]


clones: List[CloneClass] = setup()
selected_index = None


def render():
    global selected_index

    imgui.set_next_window_position(10, 10)
    imgui.set_next_window_size(280, 760)
    imgui.begin("Classes", False, imgui.WINDOW_NO_RESIZE | imgui.WINDOW_NO_MOVE | imgui.WINDOW_NO_COLLAPSE)

    for index, clone_class in enumerate(clones):
        if selected_index is index:
            label = "--> Clone class {0:3d}".format(index)
        else:
            label = "Clone class {0:3d}".format(index)

        if imgui.button(label):
            if selected_index is index:
                selected_index = None
            else:
                selected_index = index

    imgui.end()

    imgui.set_next_window_position(300, 10)
    imgui.set_next_window_size(690, 760)
    imgui.begin("Clones", False, imgui.WINDOW_NO_RESIZE | imgui.WINDOW_NO_MOVE | imgui.WINDOW_NO_COLLAPSE)

    if selected_index is not None:
        clone_class = clones[selected_index]

        for file in clone_class.files:
            expanded, visible = imgui.collapsing_header(file.file_name, None, imgui.TREE_NODE_DEFAULT_OPEN)

            if expanded:
                for entry in file.entries:
                    for index, line_number in enumerate(range(entry.begin_line, entry.end_line + 1)):
                        imgui.text("{0:3d} {1}".format(line_number, entry.content[index]))

                    imgui.spacing()
                    imgui.spacing()
                    imgui.spacing()
                    imgui.spacing()

    imgui.end()
