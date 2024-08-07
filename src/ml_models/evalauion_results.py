from typing import Any, Dict
from sklearn.metrics import (
    roc_auc_score, roc_curve, auc, accuracy_score, 
    precision_recall_curve, f1_score, classification_report, confusion_matrix,
    ConfusionMatrixDisplay
)
import matplotlib.pyplot as plt
import pandas as pd

def evaluate_model(
    y_true: pd.Series,
    y_pred: pd.Series,
    y_pred_prob: pd.Series
) -> Dict[str, Any]:
    """
    Evaluates a binary classification model on test data, returns various metrics, and directly prints the results.

    :param y_true: True labels.
    :param y_pred: Predicted binary labels.
    :param y_pred_prob: Predicted probabilities for the positive class.
    :return: A dictionary containing evaluation metrics, classification report, and confusion matrix plot.
    """

    # Calculate evaluation metrics
    roc_auc = roc_auc_score(y_true, y_pred_prob)
    fpr, tpr, _ = roc_curve(y_true, y_pred_prob)
    roc_auc_value = auc(fpr, tpr)
    test_accuracy = accuracy_score(y_true, y_pred)
    f1 = f1_score(y_true, y_pred)
    class_report = classification_report(y_true, y_pred)
    conf_matrix = confusion_matrix(y_true, y_pred)
    
    # Precision-Recall Curve
    precision, recall, _ = precision_recall_curve(y_true, y_pred_prob)
    roc_prc_value = auc(recall, precision)

    # Set up the figure and subplots
    fig, axes = plt.subplots(1, 2, figsize=(12, 6))  # Horizontal layout with sufficient size

    # Confusion Matrix Display
    ConfusionMatrixDisplay(confusion_matrix=conf_matrix).plot(ax=axes[0], cmap='Blues')
    axes[0].set_title('Confusion Matrix')
    axes[0].set_xlabel('Predicted Labels')
    axes[0].set_ylabel('True Labels')

    # ROC Curve Plot
    axes[1].plot(fpr, tpr, color='darkorange', lw=2, label=f'ROC curve (AUC = {roc_auc_value:.2f})')
    axes[1].plot([0, 1], [0, 1], color='navy', lw=2, linestyle='--')
    axes[1].set_xlim([0.0, 1.0])
    axes[1].set_ylim([0.0, 1.05])
    axes[1].set_xlabel('False Positive Rate')
    axes[1].set_ylabel('True Positive Rate')
    axes[1].set_title('Receiver Operating Characteristic')
    axes[1].legend(loc="lower right")

    plt.tight_layout()  # Adjust the layout to prevent overlap
    plt.show()

    # Package results
    evaluation_results = {
        'roc_auc': roc_auc,
        'roc_prc': roc_prc_value,
        'test_accuracy': test_accuracy,
        'f1_score': f1,
        'classification_report': class_report,
        'confusion_matrix': conf_matrix
    }

    return evaluation_results

