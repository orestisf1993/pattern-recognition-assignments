#!/usr/bin/env python
"""Module to preprocess our data and create a tree of the results"""
from __future__ import absolute_import, division, print_function
import os
import sys
import traceback
import pickle
import pandas
import treelib


class MyTree(treelib.Tree):
    """Used to override and extend some of Tree's features."""

    def create_node(self, tag=None, identifier=None, parent=None, data=None):
        return super(MyTree, self).create_node(
            tag=tag,
            identifier=tag,
            parent=parent,
            data=data)

    def get_full_path(self, node):
        """Return the full path for this node."""
        res = node
        while True:
            node = self.parent(node)
            if node is not None:
                node = node.tag
                res = os.path.join(node, res)
            else:
                return res

# override original class from module
treelib.__dict__['Tree'] = MyTree

def bool_it(dataset):
    """Convert all int values too boolean."""
    return dataset.applymap(lambda x: 1 if x else 0)

def frequency_based_selection(dataset, low_bound=8, upper_bound=50):
    """Remove some attributes that are too frequent or too infrequent."""
    to_bool = dataset.applymap(lambda x: True if x else False)
    to_bool_sums = to_bool.sum(axis=0)
    columns = to_bool_sums.axes[0]
    to_drop = [
        column
        for column, nonzeros in zip(columns, to_bool_sums)
        if nonzeros < low_bound or nonzeros > upper_bound
    ]
    return dataset.drop(to_drop, axis=1)


def join_similar(dataset, similarity_bound=0.9):
    """Try to join words that are very similar."""
    from difflib import SequenceMatcher

    def similar(first, second):
        """Similarity of 2 strings."""
        return SequenceMatcher(None, first, second).ratio()

    blacklist = [
        ('adding', 'padding'),
        ('border', 'order'),
        ('center', 'enter'),
        ('factor', 'factory'),
        ('frame', 'jframe'),
        ('getmode', 'getmodel'),
        ('preference', 'reference'),
        ('preferences', 'references'),
        ('setmode', 'setmodel'),
        ('states', 'stats'),
        ('stats', 'status')
    ]

    columns = dataset.columns
    to_join = []
    for idx, first in enumerate(columns):
        for second in columns[idx + 1:]:
            condition = (
                (first, second) not in blacklist and
                similar(first, second) > similarity_bound
            )
            if condition:
                existed = False
                for group in to_join:
                    if first in group and second in group:
                        existed = True
                        break
                    elif first in group:
                        group.append(second)
                        existed = True
                        break
                    elif second in group:
                        group.append(first)
                        existed = True
                        break
                if not existed:
                    to_join.append([first, second])
    to_drop = []
    for group in to_join:
        to_drop += group[1:]
        # sum group to the first member
        dataset[group[0]] = sum(dataset[member] for member in group)
    return dataset.drop(to_drop, axis=1)


def join_duplicates(dataset):
    """Join duplicate words."""
    return dataset.groupby(dataset.columns, axis=1).sum()

def filter_line(line, delimiter=",", startpos=2):
    """Filter and split a file's line."""
    return line.replace('\n', '').lower().split(delimiter)[startpos:]

def csv_read(filename, delimiter=",", startpos=2):
    """
    Parse csv file and return a dataframe.
    First row becames the header.
    """
    with open(filename) as file_object:
        header = filter_line(file_object.readline(), delimiter, startpos)
        return pandas.DataFrame(
            [filter_line(line, delimiter, startpos) for line in file_object],
            columns=header,
            dtype=int)

def append_class(dataset, filename='class.csv'):
    """Function to append the category as the last attribute."""
    df_class = csv_read(filename, startpos=0)
    df_concat = pandas.concat([dataset, df_class], axis=1)
    return df_concat

def save_results(dataset, directory, filename, pre_save_action=append_class):
    """Save dataset to a .pickle and .csv file."""
    if pre_save_action:
        dataset_after_action = dataset.copy(deep=True)
        dataset_after_action = pre_save_action(dataset)
    else:
        dataset_after_action = dataset
    if not os.path.exists(directory):
        os.makedirs(directory)
    with open(filename + '.pickle', 'wb') as file_object:
        pickle.dump(dataset, file_object)
    dataset_after_action.to_csv(
        filename + '.csv',
        sep=',',
        encoding='utf-8',
        index=False)

def drop_fry_words(dataset, filename='fry-words.txt'):
    """
    Drops columns that have a name that is a Fry word.
    The Fry Sight Word List is made up of the most frequently used words in
    children's books, novels, articles and textbooks.
    """
    with open(filename) as file_object:
        fry_words = []
        for line in file_object:
            fry_words += filter_line(line, delimiter=' ', startpos=0)
    to_drop = [word for word in fry_words if word in dataset.columns]
    return dataset.drop(to_drop, axis=1)

def gibberish_detector(dataset):
    """Try to delete attributes with gibberish column names."""
    lib_path = os.path.abspath(os.path.join('..', 'Gibberish-Detector'))
    if lib_path not in sys.path:
        sys.path.append(lib_path)
    import gib_detect_train

    def is_word_gibberish(word):
        """Return the result from the training."""
        return gib_detect_train.avg_transition_prob(word, model_mat) <= threshold

    try:
        with open('gib_model.pki', 'rb') as file_object:
            model_data = pickle.load(file_object)
    except (OSError, IOError) as exception:
        traceback.print_exc(file=sys.stdout)
        print("Please follow the README in Gibberish-Detector submodule"\
              "and place gib_model.pki in the datasets/ folder")
        print("Continuing without editing dataset")
        return dataset

    model_mat = model_data['mat']
    threshold = model_data['thresh']
    to_drop = [column for column in dataset.columns if is_word_gibberish(column)]
    return dataset.drop(to_drop, axis=1)

def tree_init(base_file):
    """Initialize the tree."""
    tree = treelib.Tree()
    # your tree structure here:
    # tag names currently should be unique.
    tree.create_node("root", data={
        'action': lambda _: csv_read(base_file + '.csv', delimiter=';')
    })
    tree.create_node("join_duplicates", parent="root", data={
        'action': join_duplicates
    })
    tree.create_node("frequency_based_selection", parent="join_duplicates", data={
        'action': frequency_based_selection
    })
    tree.create_node("gibberish_detector", parent="frequency_based_selection", data={
        'action': gibberish_detector
    })
    tree.create_node("join_similar", parent="gibberish_detector", data={
        'action': join_similar
    })
    tree.create_node("drop_fry_words", parent="join_similar", data={
        'action': drop_fry_words
    })
    tree.create_node("frequency_based_selection_df", parent="drop_fry_words", data={
        'action': frequency_based_selection
    })
    tree.create_node("bool_it", parent="gibberish_detector", data={
        'action': bool_it
    })
    tree.create_node("frequency_based_selection2", parent="bool_it", data={
        'action': frequency_based_selection
    })
    return tree

def main():
    """Main function."""
    base_dir = 'datasets'
    base_file = 'dataset'
    os.chdir(base_dir)
    base_dir = os.getcwd() # full path to base_dir
    file_to_print_paths = os.path.join(base_dir, 'paths.txt')
    os.remove(file_to_print_paths)

    tree = tree_init(base_file)

    for node_name in tree.expand_tree():
        directory = tree.get_full_path(node_name)
        filename = os.path.join(directory, base_file)
        filename_pickle = filename + '.pickle'
        with open(file_to_print_paths, 'a') as file_object:
            print(filename + '.csv', file=file_object)
        already_exists = os.path.exists(filename_pickle)

        node = tree.get_node(node_name)
        if already_exists:
            with open(filename_pickle, 'rb') as file_object:
                node.data['dataset'] = pickle.load(file_object)
            print('loaded: ' + filename_pickle)
            continue

        action = node.data['action']
        parent_data = None if node.is_root() else tree.parent(node_name).data['dataset'].copy(deep=True)
        node.data['dataset'] = action(parent_data)

        save_results(node.data['dataset'], directory=directory, filename=filename)
        print('----' + node_name + ' is finished')

if __name__ == '__main__':
    main()
