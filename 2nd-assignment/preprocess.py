#!/usr/bin/env python3
"""Module to preprocess our data and create a tree of the results"""
import os
import pickle
import pandas
import treelib


class MyTree(treelib.Tree):
    """Used to override and extend some of Tree's features."""

    def create_node(self, tag=None, identifier=None, parent=None, data=None):
        return super().create_node(
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
    for group in to_drop:
        to_drop += group
        # sum group to the first member
        df[group[0]] = sum(df[member] for member in group)
    return dataset.drop(to_drop, axis=1)


def join_duplicates(dataset):
    """Join duplicate words."""
    return dataset.groupby(dataset.columns, axis=1).sum()


def csv_read(filename, delimiter=";", startpos=2):
    """
    Parse csv file and return a dataframe.
    First row becames the header.
    """

    def filter_line(line):
        """Filter and split a file's line."""
        return line.replace('\n', '').lower().split(delimiter)[startpos:]

    with open(filename) as file_object:
        header = filter_line(file_object.readline())
        return pandas.DataFrame(
            [filter_line(line) for line in file_object],
            columns=header,
            dtype=int)

def apply_class(dataset, filename='class.csv'):
    """Function to append the category as the last attribute."""
    df_class = csv_read(filename, startpos=0)
    df_concat = pandas.concat([dataset, df_class], axis=1)
    return df_concat

def main():
    """Main function."""
    base_dir = 'datasets'
    base_file = 'dataset'

    tree = treelib.Tree()
    tree.create_node("root", data={
        'action': lambda _: csv_read(os.path.join(base_dir, base_file + '.csv'))
    })
    tree.create_node("join_duplicates", parent="root", data={
        'action': join_duplicates
    })
    tree.create_node("frequency_based_selection", parent="join_duplicates", data={
        'action': frequency_based_selection
    })
    tree.create_node("apply_class", parent="frequency_based_selection", data={
        'action': lambda dataset: apply_class(dataset, os.path.join(base_dir, 'class.csv'))
    })

    for node_name in tree.expand_tree():
        directory = os.path.join(base_dir, tree.get_full_path(node_name))
        filename = os.path.join(directory, base_file)
        filename_pickle = filename + '.pickle'
        already_exists = os.path.exists(filename_pickle)

        node = tree.get_node(node_name)
        if already_exists:
            with open(filename_pickle, 'rb') as file_object:
                node.data['dataset'] = pickle.load(file_object)
            print('loaded: ' + filename_pickle)
            continue

        action = node.data['action']
        parent_data = None if node.is_root() else tree.parent(node_name).data['dataset']
        node.data['dataset'] = action(parent_data)

        if not os.path.exists(directory):
            os.makedirs(directory)

        with open(filename_pickle, 'wb') as file_object:
            pickle.dump(node.data['dataset'], file_object)
        node.data['dataset'].to_csv(
            filename + '.csv',
            sep=',',
            encoding='utf-8',
            index=False)

if __name__ == '__main__':
    main()
