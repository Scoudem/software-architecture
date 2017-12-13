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


def read_all_clones() -> List[CloneClass]:
    clone_files = glob.glob(os.path.expanduser('~') + '/clones/*.txt')
    return [parse_clone_file(f) for f in clone_files]


def extract_unique_names() -> List[str]:
    file_names = []

    for clone in clones:
        file_names += [file.file_name for file in clone.files]

    file_names = list(set(file_names))
    file_names.sort()

    return file_names


def get_clones_for_file(file_name: str):
    matches = []

    for clone in clones:
        for file in clone.files:
            if file.file_name is file_name:
                matches.append((clone.class_identifier, file))

    return sorted(matches, key=lambda x: x[0])


clones: List[CloneClass] = read_all_clones()
unique_file_name: List[str] = extract_unique_names()
selected_index = None
selected_file = None
clones_for_file = None


def render():
    global selected_index, selected_file, clones_for_file

    imgui.set_next_window_position(10, 10)
    imgui.set_next_window_size(280, 375)
    imgui.begin("Clone Classes", False, imgui.WINDOW_NO_RESIZE | imgui.WINDOW_NO_MOVE | imgui.WINDOW_NO_COLLAPSE)

    for index, clone_class in enumerate(clones):

        if selected_index is clone_class.class_identifier:
            label = "--> Clone class {0:03d}".format(clone_class.class_identifier)
        else:
            label = "Clone class {0:03d}".format(clone_class.class_identifier)

        if imgui.button(label, width=260):
            if selected_index is clone_class.class_identifier:
                selected_index = None
            else:
                selected_index = clone_class.class_identifier
                selected_file = None
                clones_for_file = None

    imgui.end()

    imgui.set_next_window_position(10, 390)
    imgui.set_next_window_size(280, 380)
    imgui.begin("Files", False, imgui.WINDOW_NO_RESIZE | imgui.WINDOW_NO_MOVE | imgui.WINDOW_NO_COLLAPSE)

    for index, file_name in enumerate(unique_file_name):
        if selected_file is file_name:
            label = "--> {}".format(file_name)
        else:
            label = "{}".format(file_name)

        if imgui.button(label, width=260):
            if selected_file is file_name:
                selected_file = None
                clones_for_file = None
            else:
                selected_file = file_name
                clones_for_file = get_clones_for_file(file_name)
                selected_index = None
    imgui.end()

    imgui.set_next_window_position(300, 10)
    imgui.set_next_window_size(690, 760)
    imgui.begin("Clones", False, imgui.WINDOW_NO_RESIZE | imgui.WINDOW_NO_MOVE | imgui.WINDOW_NO_COLLAPSE)

    if selected_file is not None and clones_for_file is not None:
        for class_identifier, file in clones_for_file:
            expanded, visible = imgui.collapsing_header(
                "Clone class {0:03d}".format(class_identifier), None, imgui.TREE_NODE_DEFAULT_OPEN
            )

            if expanded:
                if imgui.button("View all files for clone class {0:03d}".format(class_identifier)):
                    selected_index = class_identifier
                    selected_file = None
                    clones_for_file = None

                for entry in file.entries:
                    for index, line_number in enumerate(range(entry.begin_line, entry.end_line + 1)):
                        imgui.text("{0:03d}\t{1}".format(line_number, entry.content[index]))

                    imgui.spacing()
                    imgui.spacing()
                    imgui.spacing()
                    imgui.spacing()

    if selected_index is not None:
        clone_class = None

        for clone in clones:
            if clone.class_identifier is selected_index:
                clone_class = clone

        for i, file in enumerate(clone_class.files):
            expanded, visible = imgui.collapsing_header(file.file_name, None, imgui.TREE_NODE_DEFAULT_OPEN)

            if expanded:
                if imgui.button("View all clones for \"{}\"".format(file.file_name)):
                    selected_file = file.file_name

                    if clones_for_file is None:
                        clones_for_file = get_clones_for_file(file.file_name)

                    selected_index = None

                for entry in file.entries:
                    for index, line_number in enumerate(range(entry.begin_line, entry.end_line + 1)):
                        imgui.text("{0:03d}\t{1}".format(line_number, entry.content[index]))

                    imgui.spacing()
                    imgui.spacing()
                    imgui.spacing()
                    imgui.spacing()

    imgui.end()
