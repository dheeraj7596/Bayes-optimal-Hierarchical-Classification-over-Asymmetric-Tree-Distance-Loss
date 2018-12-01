The “dataset_files” folder contains the raw data files along with the loss matrix and the hierarchy files for one of the smaller datasets — the CLEF

The “OVA-cascade” folder contains the main algorithm proposed in the paper. It uses a pre-built binary (for 64-bit linux) of the Liblinear SVM train function, to train two binary classifiers for every node “i” in the tree, one such that “i” alone is positive and every other class is negative, and one such that “i” and its descendants (in the tree) are positive and everything else is negative. In datasets where only leaf nodes of the hierarchy have actual training instances, only the second classifier makes sense for non-leaf nodes “i”. Once that is done the prediction is simply done according to the method suggested in the paper in file decode_tree_scores.m

The “Prob_est” folder is the logistic regression model based on the tree idea in the paper. It estimates all class probabilities and simply finds the “deepest” node whose sub-tree probability is greater than half.

