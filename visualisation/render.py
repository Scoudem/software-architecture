import glob
import json
from typing import List

import imgui
import os

import filereader
from models import CloneClass


def parse_clone_file(clone_file: str) -> List[CloneClass]:
    with open(clone_file, 'r') as file:
        data = json.load(file)
        return [CloneClass.from_json(entry) for entry in data]


def read_all_clones() -> List[CloneClass]:
    clone_files = glob.glob(os.path.expanduser('~') + '/CloneDetector/*.json')

    matches = []
    for f in clone_files:
        matches += parse_clone_file(f)

    return sorted(matches, key=lambda x: x.class_identifier)


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
            if file.file_name == file_name:
                matches.append((clone.class_identifier, file))

    return sorted(matches, key=lambda x: x[0])


clones: List[CloneClass] = read_all_clones()
unique_file_name: List[str] = extract_unique_names()
selected_index = None
selected_file = None
clones_for_file = None
file_buffers = {}
padding = 5


def select_clone(class_identifier):
    global selected_index, selected_file, clones_for_file, file_buffers

    if selected_index == class_identifier:
        selected_index = None
    else:
        selected_index = class_identifier
        selected_file = None
        clones_for_file = None

    read_files_in_buffer()


def select_file(file_name):
    global selected_index, selected_file, clones_for_file

    if selected_file == file_name:
        selected_file = None
        clones_for_file = None
    else:
        selected_file = file_name
        clones_for_file = get_clones_for_file(file_name)
        selected_index = None

    read_files_in_buffer()


def read_files_in_buffer():
    global file_buffers

    file_buffers = {}

    if selected_index is not None:
        clone_class = None

        for clone in clones:
            if clone.class_identifier == selected_index:
                clone_class = clone

        for file in clone_class.files:
            file_buffers[file.file_name] = filereader.FileBuffer(file.file_name)

    elif selected_file is not None:
        file_buffers[selected_file] = filereader.FileBuffer(selected_file)


def render():
    global selected_index, selected_file, clones_for_file, padding

    imgui.set_next_window_position(10, 10)
    imgui.set_next_window_size(280, 375)
    imgui.begin(
        "Clone Classes", False,
        imgui.WINDOW_NO_RESIZE | imgui.WINDOW_NO_MOVE | imgui.WINDOW_NO_COLLAPSE | imgui.WINDOW_MENU_BAR
    )

    if imgui.begin_menu_bar():
        if imgui.begin_menu('Sort'):
            clicked, _ = imgui.menu_item('identifier (ascending)')
            if clicked:
                clones.sort(key=lambda x: x.class_identifier)

            clicked, _ = imgui.menu_item('identifier (descending)')
            if clicked:
                clones.sort(key=lambda x: x.class_identifier, reverse=True)

            clicked, _ = imgui.menu_item('clones (ascending)')
            if clicked:
                clones.sort(key=lambda x: x.num_clones)

            clicked, _ = imgui.menu_item('clones (descending)')
            if clicked:
                clones.sort(key=lambda x: x.num_clones, reverse=True)

            clicked, _ = imgui.menu_item('files (ascending)')
            if clicked:
                clones.sort(key=lambda x: len(x.files))

            clicked, _ = imgui.menu_item('files (descending)')
            if clicked:
                clones.sort(key=lambda x: len(x.files), reverse=True)

            imgui.end_menu()

        imgui.end_menu_bar()

    for index, clone_class in enumerate(clones):

        if selected_index is clone_class.class_identifier:
            label = "--> Class {0:03d} ({1} files, {2} clones)".format(
                clone_class.class_identifier, len(clone_class.files), clone_class.num_clones
            )
        else:
            label = "Class {0:03d} ({1} files, {2} clones)".format(
                clone_class.class_identifier, len(clone_class.files), clone_class.num_clones
            )

        if imgui.button(label, width=260):
            select_clone(clone_class.class_identifier)

    imgui.end()

    imgui.set_next_window_position(10, 390)
    imgui.set_next_window_size(280, 380)
    imgui.begin("Files", False, imgui.WINDOW_NO_RESIZE | imgui.WINDOW_NO_MOVE | imgui.WINDOW_NO_COLLAPSE)

    for index, file_name in enumerate(unique_file_name):
        if selected_file is file_name:
            label = "--> {}".format(os.path.basename(file_name))
        else:
            label = "{}".format(os.path.basename(file_name))

        if imgui.button(label, width=260):
            select_file(file_name)

    imgui.end()

    imgui.set_next_window_position(300, 10)
    imgui.set_next_window_size(890, 760)
    imgui.begin(
        "Details",
        False,
        imgui.WINDOW_NO_RESIZE | imgui.WINDOW_NO_MOVE |
        imgui.WINDOW_NO_COLLAPSE | imgui.WINDOW_HORIZONTAL_SCROLLING_BAR |
        imgui.WINDOW_MENU_BAR
    )

    if selected_file is not None and clones_for_file is not None:
        if imgui.begin_menu_bar():
            if imgui.begin_menu('Actions'):
                clicked, _ = imgui.menu_item('Open in editor')

                if clicked:
                    os.system("open \"{}\"".format(selected_file))

                imgui.end_menu()

            imgui.end_menu_bar()

        file_buffer = file_buffers[selected_file]

        total_cloned_lines = 0
        for _, file in clones_for_file:
            total_cloned_lines += file.num_cloned_lines

        imgui.begin_group()
        imgui.text("Information for this file")
        imgui.bullet_text("This file contains {} lines".format(file_buffer.max_line))
        imgui.bullet_text("{} lines are cloned".format(total_cloned_lines))
        imgui.bullet_text("That is {0:.2f}% of the total file".format(total_cloned_lines / file_buffer.max_line * 100))
        imgui.end_group()

        imgui.same_line(300)

        imgui.push_item_width(200)
        imgui.begin_group()
        changed, value = imgui.slider_int("Lines of padding", padding, 0, 100)
        if changed:
            padding = value
        imgui.end_group()
        imgui.pop_item_width()

        imgui.spacing()
        imgui.spacing()
        imgui.spacing()
        imgui.spacing()

        for class_identifier, file in clones_for_file:
            expanded, visible = imgui.collapsing_header(
                "Clone class {0:03d}".format(class_identifier), None, imgui.TREE_NODE_DEFAULT_OPEN
            )

            if expanded:
                if imgui.button("View all files for clone class {0:03d}".format(class_identifier)):
                    select_clone(class_identifier)

                file_buffers[file.file_name].to_imgui(file, padding)

    if selected_index is not None:
        imgui.push_item_width(200)
        imgui.begin_group()
        changed, value = imgui.slider_int("Lines of padding", padding, 0, 100)
        if changed:
            padding = value
        imgui.end_group()
        imgui.pop_item_width()

        clone_class = None

        for clone in clones:
            if clone.class_identifier is selected_index:
                clone_class = clone

        for i, file in enumerate(clone_class.files):
            expanded, visible = imgui.collapsing_header(file.file_name, None, imgui.TREE_NODE_DEFAULT_OPEN)

            if expanded:
                if imgui.button("View all clones for \"{}\"".format(file.file_name)):
                    select_file(file.file_name)

                file_buffers[file.file_name].to_imgui(file, padding)


    imgui.end()
