# Matlab implementation for fruit detection in 3D point clouds obtained using LiDAR sensors.

## Introduction
This project is a matlab implementation for fruit detection suitable with 3D point clouds acquired with LiDAR sensor Velodyne VLP-16 (Velodyne LIDAR Inc., San Jose, CA, USA). 

This implementation was used to evaluate the LFuji-air dataset, which contains 3D LiDAR data of 11Fuji apple trees with the corresponding fruit position annotations. Find more information in:

* [Fruit detection, yield prediction and canopy geometric characterization using LiDAR with forced air flow](http://www.grap.udl.cat/en/publications/index.html).



## Preparation 


First of all, clone the code
```
git clone https://github.com/GRAP-UdL-AT/kinect_fruit_detection_faster-rcnn.pytorch.git
```

Then, create a folder:
```
cd kinect_fruit_detection_faster-rcnn.pytorch && mkdir data
```

In the data folder is where datasets and models must be stored

### prerequisites

* Python 2.7
* Pytorch 0.2.0
* CUDA 8.0 or higher

### Data Preparation

* **KFuji RGB-DS dataset**: 
Save the [KFuji RGB-DS dataset] (http://www.grap.udl.cat/en/research/index.html) in data/kinect_fruits_dataset folder. If data is anotated using [Pychet Labeller] (https://github.com/imatge-upc/pychetlabeller), it is necessary to execute square_annot_from_pychet_rectangle.py.

### Pretrained Model

We used VGG pretrained model in our experiments. You can download this model from:

* VGG16: [Dropbox](https://www.dropbox.com/s/s3brpk0bdq60nyb/vgg16_caffe.pth?dl=0), [VT Server](https://filebox.ece.vt.edu/~jw2yang/faster-rcnn/pretrained-base-models/vgg16_caffe.pth)

Download and put it into the data/kinect_fruits_models/.

**NOTE**. That is not a faster-rcnn pretrained model, is just a pretrained VGG16 model to start to train "from scratch" the faster_rcnn part

### Compilation

As pointed out by [ruotianluo/pytorch-faster-rcnn](https://github.com/ruotianluo/pytorch-faster-rcnn), choose the right `-arch` in `lib/make.sh` file, to compile the cuda code:

  | GPU model  | Architecture |
  | ------------- | ------------- |
  | TitanX (Maxwell/Pascal) | sm_52 |
  | GTX 960M | sm_50 |
  | GTX 1080 (Ti) | sm_61 |
  | Grid K520 (AWS g2.2xlarge) | sm_30 |
  | Tesla K80 (AWS p2.xlarge) | sm_37 |
  
More details about setting the architecture can be found [here](https://developer.nvidia.com/cuda-gpus) or [here](http://arnon.dk/matching-sm-architectures-arch-and-gencode-for-various-nvidia-cards/)

For selecting the gpu architecture there are examples in makesh_examples/ so copy that as lib/make.sh

Information of the GPUs architecture of the imatge server is at:
[imatge.upc.edu information](https://imatge.upc.edu/trac/wiki/DevelopmentPlatform/HardwareResources)

Install all the python dependencies using pip:
```
pip install -r requirements.txt
```

Compile the cuda dependencies using following simple commands:

```
cd lib
srun --gres=gpu:pascal:1,gmem:6G --mem 12G sh make.sh
or
srun --gres=gpu:maxwell:1,gmem:6G --mem 12G sh make.sh

```

It will compile all the modules you need, including NMS, ROI_Pooing, ROI_Align and ROI_Crop. The default version is compiled with Python 2.7, please compile by yourself if you are using a different python version.

**IMPORTANT NOTE** The srun --gres... until python script execution has to be the same of what used in compilation of make.sh

## Train/val

Execute trainval to do the train and validation in the same script
```
srun --gres:$architecture:1,gmem:6G --mem 30G -c 2 python trainval_net.py \
              --dataset kinect_fruits --net vgg16_5ch \
              --bs $BATCH_SIZE --lr $LEARNING_RATE  \
              --lr_decay_step $DECAY_STEP --RGB --NIR --DEPTH  \
		   --epochs $NUM_EPOCHS --o $OPTIMIZER \
		   --s $SESSION --anchor $ANCHOR_SCALE --cuda
```

example:
```
srun --gres=gpu:1,gmem:10G --mem 30G -c 2 python trainval_net.py --dataset kinect_fruits_k --net vgg16_5ch --bs 4  --lr 0.0001 --lr_decay_step 10 --RGB --NIR  --DEPTH  --epochs 45 --o adam --s 60  --anchor 4  --anchor 8  --anchor 16  --cuda
```


These script only compute the loss

## Test

If you want to evlauate the detection performance of a pre-trained faster-rcnn model on kinect_fruits test set, simply run
```
srun --gres:$architecture:1,gmem:6G --mem 30G python test_net.py\
		   --dataset kinect_fruits --net vgg16_5ch \
		   --RGB --DEPTH --NIR --cheksession $SESSION\
		   --checkpoint $POINT --anchor $ANCHOR_SCALE \
		   --ovthresh $minIOU --minconfid $minCONFIDENCE\
		   --cuda
```

example:
```
srun --gres=gpu:1,gmem:10G --mem 30G -c 2 python test_net.py --dataset kinect_fruits_k --net vgg16_5ch  --RGB  --DEPTH  --NIR   --checksession 60 --checkpoint 309  --anchor 4  --anchor 8  --anchor 16   --ovthresh 0.2 --minconfid 0.4 --minconfid 0.45 --minconfid 0.5  --minconfid 0.55  --minconfid 0.6 --minconfid 0.65 --minconfid 0.7   --cuda
```

This script computes mean average precision, precision, recall, F1-score and the number of inferred images per second. 




## Demo

If you want to run detection on your own images with a pre-trained model, download the pretrained model or train your own models at first, then add images to folder $ROOT/images_kinect_fruits, and then run
```
srun --gres=gpu:1,gmem:10G --mem 30G -c 2 python demo.py \
		   --dataset kinect fruits --net vgg16_5ch \
		   --RGB --DEPTH --NIR --cheksession $SESSION\
		   --checkpoint $POINT --checkepoch $epoch \
		   --anchor $ANCHOR_SCALE --minconfid $minCONFIDENCE\
		   --image_dir images_kinect_fruits --cuda

```
example:
```
srun --gres=gpu:1,gmem:10G --mem 30G -c 2 python demo.py --dataset kinect_fruits --net vgg16_5ch  --RGB  --DEPTH  --NIR   --checksession 42 --checkpoint 309  --checkepoch 12  --anchor 4  --anchor 8  --anchor 16    --minconfid 0.6  --image_dir images_kinect_fruits  --cuda
```

Then you will find the detection results in folder $ROOT/images_kinect_fruits. 


## Authorship

This project is contributed by [GRAP-UdL-AT](http://www.grap.udl.cat/en/index.html) and [ImageProcessingGroup-UPC](https://imatge.upc.edu/web/) and it is based on the implementation of[Jianwei Yang](https://github.com/jwyang).

Please contact authors to report bugs @ j.gene@eagrof.udl.cat


## Citation

If you find this implementation or the analysis conducted in our report helpful, please consider citing:

    @article{Gené-Mola2018,
        Author = {Gen{\'e}-Mola, Jordi and Morros, Josep-Ramon and Rosell-Polo, Joan R and Ruiz-Hidalgo, Javier and Vilaplana, Ver{\'o}nica and Gregorio, Eduard},
        Title = {Multi-modal Deep Learning for Fruit Detection Using RGB-D Cameras and their Radiometric Capabilities},
        Journal = {Submitted},
        Year = {2018}
    } 

For convenience, here is the faster RCNN citation:

    @inproceedings{renNIPS15fasterrcnn,
        Author = {Shaoqing Ren and Kaiming He and Ross Girshick and Jian Sun},
        Title = {Faster {R-CNN}: Towards Real-Time Object Detection
                 with Region Proposal Networks},
        Booktitle = {Advances in Neural Information Processing Systems ({NIPS})},
        Year = {2015}
    }
