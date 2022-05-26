trainFile = 'D:\elena\mspi\output\pslRaw32Augmented\000-Datasets\hsi_pslRaw32Augmented_train.h5';
testFile = 'D:\elena\mspi\output\pslRaw32Augmented\000-Datasets\hsi_pslRaw32Augmented_test.h5';


trainNames = h5info(trainFile);
trSampleNames = {trainNames.Groups.Name};
Xtrain = zeros( numel(trSampleNames), 32, 32, 311); 
ytrain = zeros(numel(trSampleNames), 32, 32); 
for i =1:numel(trSampleNames)
    Xtrain(i,:,:,:) = h5read(trainFile, strcat(trSampleNames{i}, '/hsi'));
    ytrain(i,:,:) = h5read(trainFile, strcat(trSampleNames{i}, '/label'));
end

testNames = h5info(testFile);
teSampleNames = {testNames.Groups.Name};
Xtest = zeros(numel(teSampleNames), 32, 32, 311); 
ytest = zeros(numel(teSampleNames), 32, 32); 
for i =1:numel(teSampleNames)
    Xtest(i, :,:,:) = h5read(testFile, strcat(teSampleNames{i}, '/hsi'));
    ytest(i, :,:) = h5read(testFile, strcat(teSampleNames{i}, '/label'));
end

ytest = categorical(ytest);
ytrain = categorical(ytrain);

imageSize = [32 32 311];
numClasses = 2;

lgraph = resnetLayers(imageSize,numClasses, ...
    InitialStride=1, ...
    InitialFilterSize=3, ...
    InitialNumFilters=16, ...
    StackDepth=[4 3 2], ...
    NumFilters=[16 32 64]);


options = trainingOptions("sgdm", ...
    MaxEpochs=5, ...
    InitialLearnRate=0.1, ...
    Verbose=false, ...
    Plots="training-progress");


net = trainNetwork(Xtrain,ytrain,lgraph,options);
