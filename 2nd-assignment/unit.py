#!/usr/bin/env python
import unittest
import pandas
import random
import preprocess  # our module
from pprint import pprint


class TestPreprocess(unittest.TestCase):
    NROWS = 10

    def generate_rows(self, columns):
        return [
            [random.randint(0, 50) for _ in range(len(columns))]  # random row
            for _ in range(self.NROWS)]

    def test_join_similar_with_blacklist(self):
        # create a test dataset
        columns = [
            'adding',
            'awordorsomething',
            'getawordorsomething',
            'padding',
            'word1',
            'word2']
        rows = self.generate_rows(columns)
        dataset = pandas.DataFrame(data=rows, columns=columns, dtype=int)
        result = preprocess.join_similar(dataset.copy(deep=True), 0.9)

        # create expected result dataset
        expected_columns = columns[:]
        expected_columns.pop(2)
        expected_rows = [
            row[:2] + row[3:] for row in rows]
        for idx, expected_row in enumerate(expected_rows):
            expected_rows[idx][1] += rows[idx][2]
        expected_result = pandas.DataFrame(
            data=expected_rows, columns=expected_columns, dtype=int)

        # make the test
        self.assertTrue(expected_result.equals(result))

    def test_join_similar_recursive(self):
        columns = [
            'awordorsomething',
            'getawordorsomething',
            'getawordorsomethingelse'
        ]
        rows = self.generate_rows(columns)
        dataset = pandas.DataFrame(data=rows, columns=columns, dtype=int)
        result = preprocess.join_similar(dataset.copy(deep=True), 0.9)

        # create expected result dataset
        expected_columns = columns[:1]  # all should be merged to the first
        expected_rows = [
            row[:1] for row in rows]
        for idx, expected_row in enumerate(expected_rows):
            expected_rows[idx][0] += rows[idx][1] + rows[idx][2]
        expected_result = pandas.DataFrame(
            data=expected_rows, columns=expected_columns, dtype=int)

        # make the test
        self.assertTrue(expected_result.equals(result))

if __name__ == '__main__':
    unittest.main()
