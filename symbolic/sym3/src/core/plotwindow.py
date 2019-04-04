import sys

from PyQt5.QtWidgets import QMainWindow, QApplication, QVBoxLayout, QDesktopWidget, QWidget
from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure

class PlotWindow(QMainWindow):
    def __init__(self, data):
        super().__init__()
        self.initializeUI(data)

    def initializeUI(self, data):
        self.setWindowTitle('График')
        self.setGeometry(0, 0, 500, 400)
        self.setMinimumSize(400, 320)
        self.center()
        self.setFocus()

        self._main = QWidget()
        self.setCentralWidget(self._main)
        layout = QVBoxLayout(self._main)
        self.setLayout(layout)

        self.figure = Figure()
        self.canvas = FigureCanvas(self.figure)
        layout.addWidget(self.canvas)

        self.plot(data)

    def center(self):
        screen_center = QDesktopWidget().availableGeometry().center()
        frame = self.frameGeometry()
        frame.moveCenter(screen_center)
        self.move(frame.topLeft())

    def plot(self, data):
        for xs, ys, label in data:
            ax = self.figure.add_subplot(111)
            ax.plot(xs, ys, label=label)
            ax.legend()
        self.canvas.draw()


def createPlot(data):
    app = QApplication(sys.argv)
    window = PlotWindow(data)
    window.show()
    app.exec_()