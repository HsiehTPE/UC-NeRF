import imp
from .scared import ScaredDataset
from .hamlyn import HamlynDataset
from .c3vd import C3VDDataset
dataset_dict = {
                'scared': ScaredDataset,
                'hamlyn': HamlynDataset,
                'c3vd': C3VDDataset}
