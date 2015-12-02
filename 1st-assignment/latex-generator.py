#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function
import weka.core.jvm as jvm
from weka.core.converters import Loader
from weka.classifiers import Evaluation
from weka.core.classes import Random
from weka.core.classes import from_commandline
import numpy as np
import sys
import os
import json

BASE_LATEX_STRING = r'''\subsection{{{section_name}}}
\begin{{description}}
\begin{{minipage}}{{1.0\linewidth}}
\item \textbf{{Εντολή:}}

\begin{{lstlisting}}[language=Java, numbers=none, breaklines=true]
{cli}
\end{{lstlisting}}
\end{{minipage}}

\begin{{minipage}}{{1.0\linewidth}}
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
\end{{minipage}}

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
\label{{tab:conf-{code_name}}}
\end{{center}}

\item \textbf{{Σχόλια:}}
\input{{algorithms/{code_name}-comments}}
\end{{description}}
'''

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

    with open('algorithms/' + code_name + '.tex', 'w') as f:
        f.write(BASE_LATEX_STRING.format(**replace_dict))

    comments_filename = 'algorithms/' + code_name + '-comments.tex'
    if not os.path.exists(comments_filename):
        open(comments_filename, 'w').close()

def use_classifier(data_filename, cli):
    loader = Loader(classname="weka.core.converters.ArffLoader")
    data = loader.load_file(data_filename)
    data.class_is_last()
    cls = from_commandline(cli, classname="weka.classifiers.Classifier")
    cls.build_classifier(data)
    evaluation = Evaluation(data)
    evaluation.crossvalidate_model(cls, data, 10, Random(1))
    return cls, evaluation

def main(args):
    with open(args[1]) as f:
        opts = json.load(f)
    cls, evl = use_classifier(opts['data'], opts['cli'])
    generate_latex_table(cls, evl, opts['code_name'], opts['section_name'])
    return 0
if __name__ == '__main__':
    try:
        jvm.start()
        sys.exit(main(sys.argv))
    except Exception as e:
        import traceback
        print(traceback.format_exc(), file=sys.stderr)
    finally:
        jvm.stop()
