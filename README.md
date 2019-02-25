# Matlab implementation for fruit detection in 3D LiDAR point clouds.

## Introduction
This project is a matlab implementation for fruit detection in 3D point clouds acquired with LiDAR sensor Velodyne VLP-16 (Velodyne LIDAR Inc., San Jose, CA, USA). 

This implementation was used to evaluate the [LFuji-air dataset](http://www.grap.udl.cat/en/publications/LFuji_air_dataset.html), which contains 3D LiDAR data of 11Fuji apple trees with the corresponding fruit position annotations. Find more information in:

* [Fruit detection, yield prediction and canopy geometric characterization using LiDAR with forced air flow [1]](http://www.grap.udl.cat/en/publications/index.html) (submitted, not publicly available yet).



## Preparation 


First of all, clone the code
```
git clone https://github.com/ GRAP-UdL-AT/fruit_detection_in_LiDAR_pointClouds.git
```

Then, create a folder named “data” in the same directory where the code were saved.
Inside the /data folder, save the ground truth and point cloud data (“AllTrees_Groundtruth” and “AllTrees_pcloud”) available at [LFuji-air dataset](http://www.grap.udl.cat/en/publications/LFuji_air_dataset.html).


### Pre-requisites

* MATLAB R2018 (we have not tested it in other matlab vercions)
* Computer Vision System Toolbox
* Statistics and Machine Learning Toolbox

### Data Preparation

* **LFuji-air dataset**: 
Save the [LFuji-air dataset](http://www.grap.udl.cat/en/publications/LFuji_air_dataset.html) in /data folder.

## Cross-vailidation test (fruit detection)

Open the matlab file *main_CrossVal_Velodyne_fruit_detection.m* and set the following parameters:
```
directory = $”code_directory”$;  % Write the directory where the code and the /data folder are placed.
Trials2eval = ${trials_to_evaluate}$;  %List the trials to evaluate
```
example:
```
directory = 'F:\fruit_detection\vel_air';  
Trials2eval = {'H1_n_E_O','H1_n_E','H1_n_O','H1_H2_n_E_O','H1_n_af_E_O'}; 
```
Execute the file *main_CrossVal_Velodyne_fruit_detection.m*.

## Train (fruit detection)
Open the matlab file *main_ Velodyne_fruit_detection.m* and set the following parameters:
```
directory = $”code_directory”$. %Write the directory where the code and the /data folder are placed.
pcDiectory_txt = strcat(directory, $”training_data_folder”$ ); %Write the name of the training data folder.
train = $logical_number$; %Set this parameter to 1 for training the svm models.
```
example:
```
directory = 'F:\fruit_detection\vel_air';  
pcDiectory_txt = strcat(directory, '\data\TrainingData\');
train = 1;
```
Execute the file *main_ Velodyne_fruit_detection.m*.

## Test (fruit detection)
Open the matlab file *main_ Velodyne_fruit_detection.m* and set the following parameters:
```
directory = $”code_directory”$. %Write the directory where the code and the /data folder are placed.
pcDiectory_txt = strcat(directory, $”test_data_folder”$ ); %Write the name of the test data folder.
train = $logical_number$; %Set this parameter to 0 to test data using a previously trained svm models.
```
example:
```
directory = 'F:\fruit_detection\vel_air';  
pcDiectory_txt = strcat(directory, '\data\TestData\');
train = 0;
```
Execute the file *main_ Velodyne_fruit_detection.m*.

## Canopy geomtry characterization
In [[1]]((http://www.grap.udl.cat/en/publications/index.html)), the [LFuji-air dataset](http://www.grap.udl.cat/en/publications/LFuji_air_dataset.html) is used to evaluate the fruit detection performance, but also to compute canopy geometrical measurements such as mean height, mean width, canopy contour, mean canopy cross section and leave area. To compute this canopy geometrical parameters from a 3D LiDAR point cloud, do the following:

Open the matlab file *main_ Velodyne_LA_meanShape.m* and set the following parameters:
```
directory = $”code_directory”$;  % Write the directory where the code and the /data folder are placed.
Trials2eval = ${trials_to_evaluate}$;  %List the trials to evaluate
```
example:
```
directory = 'F:\fruit_detection\vel_air';  
Trials2eval = {'H1_n_E_O','H1_n_E','H1_n_O','H1_H2_n_E_O','H1_n_af_E_O'}; 
```
Execute the file *main_ Velodyne_LA_meanShape.m*.

## Authorship

This project is contributed by [GRAP-UdL-AT](http://www.grap.udl.cat/en/index.html).

Please contact authors to report bugs @ j.gene@eagrof.udl.cat


## Citation

If you find this implementation or the analysis conducted in our report helpful, please consider citing:

    @article{Gené-Mola2019,
        Author = {Gen{\'e}-Mola, Jordi and Gregorio, Eduard and Auat Cheein, Fernando and Guevara, Javier and Llorens, Jordi and Sanz-Cortiella, Ricardo and Escol{\`a}, Alexandre and Rosell-Polo, Joan R},
        Title = {Fruit detection, yield prediction and canopy geometric characterization using LiDAR with forced air flow},
        Journal = {Submitted},
        Year = {2019}
    } 

## References

[[1] Gené-Mola J, Gregorio E, Auat Cheein F, Guevara J, Llorens J, Sanz-Cortiella R, Escolà A, Rosell-Polo JR. 2019. Fruit detection, yield prediction and canopy geometric characterization using LiDAR with forced air flow (Submitted)](http://www.grap.udl.cat/en/publications/index.html).
