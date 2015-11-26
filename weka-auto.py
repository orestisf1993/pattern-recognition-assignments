#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function
import weka.core.jvm as jvm
from weka.core.converters import Loader
from weka.attribute_selection import ASSearch, ASEvaluation, AttributeSelection
from weka.classifiers import Classifier
from weka.filters import Filter
from weka.classifiers import Evaluation
from weka.core.classes import Random
from weka.core.classes import from_commandline
import numpy as np
import itertools
import sys
import time
import os

BASE_LATEX_STRING = r'''\subsection{{{section_name}}}
\begin{{description}}
\item \textbf{{Εντολή:}}

\begin{{lstlisting}}[language=Java, numbers=none, breaklines=true]
{cli}
\end{{lstlisting}}

\item \textbf{{Αποτελέσματα}}:

\begin{{center}}
\begin{{tabular}}{{l|cccc}}
 & precision & recall & f-measure & accuracy \\
class 0 & {precision0} & {recall0} & {fmeasure0} & -\\
class 1 & {precision1} & {recall1} & {fmeasure1} & - \\
weighted & {wprecision} & {wrecall} & {wfmeasure} & {accuracy}\% \\
\end{{tabular}}
\captionof{{table}}{{Αποτελέσματα {section_name}}}
\label{{tab:{code_name}}}
\end{{center}}

\begin{{center}}
\begin{{tabular}}{{l|c|c|c|c}}
\multicolumn{{2}}{{c}}{{}}&\multicolumn{{2}}{{c}}{{Predicted}}&\\
\cline{{3-4}}
\multicolumn{{2}}{{c|}}{{}}&0&1&\multicolumn{{1}}{{c}}{{Total}}\\
\cline{{2-4}}
\parbox[t]{{2mm}}{{\multirow{{2}}{{*}}{{\rotatebox[origin=c]{{90}}{{Actual}}}}}} & 0 & ${a}$ & ${b}$ & ${ab}$\\
\cline{{2-4}}
& 1 & ${c}$ & ${d}$ & ${cd}$\\
\cline{{2-4}}
\multicolumn{{1}}{{c}}{{}} & \multicolumn{{1}}{{c}}{{Total}} & \multicolumn{{1}}{{c}}{{${ac}$}} & \multicolumn{{1}}{{c}}{{${bd}$}} & \multicolumn{{1}}{{c}}{{${abcd}$}}\\
\end{{tabular}}
\captionof{{table}}{{Confusion Matrix {section_name}}}
\label{{tab:{code_name}}}
\end{{center}}

\item \textbf{{Σχόλια:}}
\input{{algorithms/{code_name}-comments}}
\end{{description}}'''

DATA_FILE = r"out-edited.arff"
#~ DATA_FILE = r"PCA.arff"

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

def generate_latex_table(cls, evl, code_name, section_name):
    a = int(evl.confusion_matrix[0][0])
    b = int(evl.confusion_matrix[0][1])
    c = int(evl.confusion_matrix[1][0])
    d = int(evl.confusion_matrix[1][1])
    replace_dict = {
        'code_name': code_name,
        'section_name': section_name,
        'cli': cls.to_commandline(),
        'precision0': evl.precision(0),
        'precision1': evl.precision(1),
        'recall0': evl.recall(0),
        'recall1': evl.recall(1),
        'fmeasure0': evl.f_measure(0),
        'fmeasure1': evl.f_measure(1),
        'wprecision': evl.weighted_precision,
        'wrecall': evl.weighted_recall,
        'wfmeasure': evl.weighted_f_measure,
        'accuracy': evl.percent_correct,
        'a': a,
        'b': b,
        'c': c,
        'd': d,
        'ab': a+b,
        'cd': c+d,
        'ac': a+c,
        'bd': b+d,
        'abcd': a+b+c+d
    }
    for key,val in replace_dict.items():
        if isinstance(val, float):
            s = '{0:.2f}' if key == 'accuracy' else '{0:.4f}'
            replace_dict[key] = s.format(val)

    with open(code_name + '.tex', 'w') as f:
        f.write(BASE_LATEX_STRING.format(**replace_dict))

    comments_filename = code_name + '-comments.tex'
    if not os.path.exists(comments_filename):
        open(comments_filename, 'w').close()

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

    if (len(sys.argv) >= 2):
        import pickle
        d = pickle.load(sys.argv[1])
        perms = d['perms']
        old_maxf = d['curr_maxf']
        old_bestcli = d['curr_bestcli']
        cli = d['cli']
        del d
        call_expirement(cli)
        if old_maxf > curr_maxf:
            print('\n' + str(old_bestcli))
        else:
            print('\n' + str(curr_bestcli))
    else:
        expirements = [

                {'cli':r'weka.classifiers.meta.CostSensitiveClassifier -cost-matrix "[0.0 1.0; {cost} 0.0]" -S 1 -W weka.classifiers.lazy.IBk -do-not-check-capabilities -- -K {K} -W 0 -{weight} -A "weka.core.neighboursearch.LinearNNSearch -A \"weka.core.EuclideanDistance -R first-last\""', 'cost':np.linspace(4.5, 5.5, 5), 'K':range(1, 20), 'weight':['I', 'F']}
                #~ {'cli':r'weka.classifiers.meta.CostSensitiveClassifier -cost-matrix "[0.0 1.0; {cost} 0.0]" -S 1 -W weka.classifiers.functions.SMO -do-not-check-capabilities -- -no-checks -C {costsvm} -L 0.001 -P 1.0E-12 -N 0 -V -1 -W 1 -K "weka.classifiers.functions.supportVector.NormalizedPolyKernel -E {e} -C 0 -no-checks" -do-not-check-capabilities', 'cost':np.linspace(4.5, 5.5, 5), 'costsvm':np.linspace(0.5, 2, 10), 'e':np.linspace(2,8,4)}
                #~ {'cli': r'weka.classifiers.meta.CostSensitiveClassifier -cost-matrix "[0.0 1.0; {cost} 0.0]" -S 1 -W weka.classifiers.functions.LibSVM -do-not-check-capabilities -- -S 0 -K 2 -D 3 -G {gamma} -R 0.0 -N 0.5 -M 400.0 -C {costsvm} -E 0.01 -P 0.1 -W "1.0 {weight}" -model /home/orestis -seed 1', 'cost': np.linspace(4.5, 5.5, 5), 'costsvm':np.linspace(0.5, 2, 10), 'weight': np.linspace(1,5,5), 'gamma':np.linspace(0.0,2*10**(-2),3)}
            #~ {
                #~ 'cli': r'weka.classifiers.meta.CostSensitiveClassifier -cost-matrix "[0.0 1.0; {cost} 0.0]" -S 1 -W weka.classifiers.trees.RandomForest -- -I 100 -K 0 -S 1 -num-slots 4',
                #~ 'cost': np.linspace(0.01, 7, 100)
            #~ },
            #~ {
                #~ 'cli': r'weka.classifiers.meta.AttributeSelectedClassifier -E "weka.attributeSelection.ClassifierSubsetEval -B weka.classifiers.meta.CostSensitiveClassifier -T -H \"Click to set hold out or test instances\" -E f-meas -- -cost-matrix \"[0.0 1.0; {cost} 0.0]\" -S 1 -W weka.classifiers.trees.J48 -- -C {conf} -M 2" -S "weka.attributeSelection.BestFirst -D 1 -N 10" -W weka.classifiers.meta.CostSensitiveClassifier -- -cost-matrix "[0.0 1.0; {cost} 0.0]" -S 1 -W weka.classifiers.meta.Bagging -- -P 100 -S 1 -num-slots 6 -I 10 -W weka.classifiers.trees.J48 -- -C {conf} -M 2',
                #~ 'cost': np.linspace(0.01, 6, 35),
                #~ 'conf': np.linspace(0.01, 0.30, 55)
            #~ }
        ]
        for expirement in expirements:
            cli = expirement.pop('cli')
            perms = [dict(zip(expirement, v)) for v in itertools.product(*expirement.values())]
            call_expirement(cli)
            print('\n' + str(curr_bestcli))

if __name__ == "__main__":
    try:
        jvm.start()
        loader = Loader(classname="weka.core.converters.ArffLoader")
        data_dir = r'/home/orestis/Downloads/protupa/'
        data = loader.load_file(data_dir + DATA_FILE)
        data.class_is_last()
        main()
    except Exception as e:
        import pickle
        print('Saving data!', file=sys.stderr)
        with open('dump' + time.strftime('%d-%m-%Y-%H-%M-%S') + '.pickle', 'wb') as f:
            pickle.dump({'perms': perms[curr_count:],
                         'curr_maxf': curr_maxf, 'curr_bestcli': curr_bestcli}, f)
        import traceback
        print(traceback.format_exc(), file=sys.stderr)
    finally:
        jvm.stop()
