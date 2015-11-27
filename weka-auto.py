#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function
import weka.core.jvm as jvm
from weka.core.converters import Loader
from weka.classifiers import Classifier
from weka.classifiers import Evaluation
from weka.core.classes import Random
from weka.core.classes import from_commandline
import numpy as np
import itertools
import sys
import time
import os

DATA_FILE = r"out-edited.arff"
#~ DATA_FILE = r"PCA.arff"
DATA_DIR = r'~/Downloads/protupa/'

try:
    import progressbar
    def create_progressbar(max_value):
        return progressbar.ProgressBar(widgets=[
            ' [', progressbar.Timer(), '] ',
            progressbar.Bar(),
            ' (', progressbar.ETA(), ') ',
        ], fd=sys.stderr, max_value=max_value, redirect_stderr=True)
except:
    def create_progressbar():
        def custom_count(a):
            total = len(a)
            for idx, element in enumerate(a):
                sys.stderr.write('{count} / {total}'.format(count=idx + 1, total=total) + '\n')
                sys.stderr.flush()
                yield element
        return custom_count

def round_closest_half(number):
    return round(number * 2) / 2


def cost_function_alt(evl):
    f_measure = evl.f_measure(1)
    acc = evl.percent_correct / 100
    recall = evl.recall(1)
    res = f_measure / 2 + acc / 6 + recall / 3
    print(f_measure, acc, recall, '->', res)
    return res


def cost_function(evl):
    f_measure = evl.f_measure(1)
    return round_closest_half(f_measure * 100) + evl.recall(1)


def use_classifier(data, cli, args):
    cli = cli.format(cli, **args)
    cls = from_commandline(cli, classname="weka.classifiers.Classifier")
    cls.build_classifier(data)
    evaluation = Evaluation(data)
    evaluation.crossvalidate_model(cls, data, 10, Random(1))
    return cls, evaluation

curr_maxf = float('-Inf')
curr_count = 0
curr_bestcli = ''

def call_expirement(cli):
    global curr_maxf
    global curr_count
    global curr_bestcli
    curr_maxf = float('-Inf')
    bar = create_progressbar(len(perms))
    for curr_count, combination in enumerate(perms):
        cls, evl = use_classifier(data, cli, combination)
        res = cost_function(evl)
        print(cls.to_commandline(), '===>', res, file=sys.stdout)
        if res > curr_maxf:
            curr_maxf = res
            curr_bestcli = cls.to_commandline()
        bar.update(curr_count)

def main():
    # load data
    global perms

    expirements = [
            {'cli': r'weka.classifiers.meta.CostSensitiveClassifier -cost-matrix "[0.0 1.0; {cost} 0.0]" -S 1 -W weka.classifiers.functions.SMO -do-not-check-capabilities -- -no-checks -C {costsvm} -L 0.001 -P 1.0E-12 -N {N} -V -1 -W 1 -K "weka.classifiers.functions.supportVector.RBFKernel -G {gamma} -C 0 -no-checks" -do-not-check-capabilities', 'gamma':np.linspace(0.00,0.2,5), 'costsvm':np.linspace(0.7,3,20), 'cost': np.linspace(2, 10, 20), 'N':[0,1]}
            # ~ {'cli': r'weka.classifiers.meta.CostSensitiveClassifier -cost-matrix "[0.0 1.0; {cost} 0.0]" -S 1 -W weka.classifiers.functions.SMO -do-not-check-capabilities -- -no-checks -C {costsvm} -L 0.001 -P 1.0E-12 -N {N} -V -1 -W 1 -K "weka.classifiers.functions.supportVector.NormalizedPolyKernel -E 4.0 -C 0 -no-checks" -do-not-check-capabilities', 'gamma':np.linspace(0.00,0.2,5), 'costsvm':np.linspace(0.7,3,20), 'cost': np.linspace(2, 10, 20), 'N':[0,1]}
            # ~ {'cli': r'weka.classifiers.meta.CostSensitiveClassifier -cost-matrix "[0.0 1.0; {cost} 0.0]" -S 1 -W weka.classifiers.functions.LibSVM -do-not-check-capabilities -- -S 0 -K 2 -D 4 -G {gamma} -R 0.0 -N 0.3 -M 400.0 -C {costsvm} -E 0.01 -P 0.1 -V -model /home/orestis -seed 1', 'gamma':np.linspace(0.00,0.2,5), 'costsvm':np.linspace(0.7,3,50), 'cost': np.linspace(4, 6, 20)}
            # ~ {'cli':r'weka.classifiers.meta.AttributeSelectedClassifier -E "weka.attributeSelection.ClassifierSubsetEval -B weka.classifiers.meta.CostSensitiveClassifier -T -H \"Click to set hold out or test instances\" -E f-meas -- -cost-matrix \"[0.0 1.0; {cost} 0.0]\" -S 1 -W weka.classifiers.trees.J48 -do-not-check-capabilities -- -C 0.15 -M 2 -do-not-check-capabilities" -S "weka.attributeSelection.BestFirst -D 1 -N 10" -W weka.classifiers.meta.CostSensitiveClassifier -do-not-check-capabilities -- -cost-matrix "[0.0 1.0; {cost} 0.0]" -S 1 -W weka.classifiers.meta.Bagging -do-not-check-capabilities -- -P 100 -S 1 -num-slots 6 -I 10 -W weka.classifiers.trees.J48 -do-not-check-capabilities -- -C {conf} -M 2 -do-not-check-capabilities', 'cost': np.linspace(4, 6, 20), 'conf':np.linspace(0.05,0.2,5)}
    ]
    for expirement in expirements:
        cli = expirement.pop('cli')
        perms = [dict(zip(expirement, v)) for v in itertools.product(*expirement.values())]
        call_expirement(cli)
        print('\n\n' + str(curr_bestcli))

if __name__ == "__main__":
    try:
        jvm.start()
        loader = Loader(classname="weka.core.converters.ArffLoader")
        data = loader.load_file(os.path.join(DATA_DIR, DATA_FILE))
        data.class_is_last()
        main()
    except Exception as e:
        import traceback
        print(traceback.format_exc(), file=sys.stderr)
    finally:
        jvm.stop()
