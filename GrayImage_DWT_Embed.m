close all
clear 

% Read Audio and Image 
[audio,fs]=audioread('around_the_world-atc.wav');
image=imread('lena.jpg');

% GrayScale Image conversion 
grayimage=rgb2gray(image);
size_grayimage=size(grayimage);
conv_binary=uint8(zeros(size_grayimage(1,1),size_grayimage(1,2)*8));


%Grayscale to Binary Conversion 
for i=1:size_grayimage(1,1) 
    char_array=zeros(1,8);
    for j=1:size_grayimage(1,2)
        char_array=dec2bin(grayimage(i,j),8);
        char_array=uint8(char_array);
        char_array=char_array-48;
        for k=1:8
            conv_binary(i,(j-1)*8+k)=char_array(k);
        end;
    end;
end;

conv_binary_single=reshape(conv_binary,[size_grayimage(1,1)*size_grayimage(1,2)*8,1]);
conv_binary_single=double(conv_binary_single);
% Divide Audio into Blocks
ElementsPerSegment=128;
No_Of_Segments=ceil(length(audio)/ElementsPerSegment);
audiosegment=zeros(No_Of_Segments,ElementsPerSegment);
for i=1:No_Of_Segments
for j= 1:ElementsPerSegment
    if((128*(i-1) +j)<=length(audio))
       audiosegment(i,j)=audio(128*(i-1) +j);
    end;
end;
end;


for i=1:No_Of_Segments 
[C(i,:),L(i,:)]=wavedec(audiosegment(i,:),3,'haar');
[cd1(i,:),cd2(i,:),cd3(i,:)] = detcoef(C(i,:),L(i,:),[1 2 3]);
[maximuma(i),indexa(i)]=max(cd3(i,:));
end;

size_conv_binary_single=length(conv_binary_single); 
for i=1:size_conv_binary_single
    if conv_binary_single(i,1)==0 
        alpha(i)=0;
    else
        alpha(i)=double(sqrt(sum(cd3(i,:).^2)*0.001)/conv_binary_single(i,1));

    end;  
end;

for i=1:size_conv_binary_single
    cd3(i,indexa(i))=cd3(i,indexa(i))+alpha(1,i)*conv_binary_single(i,1);
end;

for i=1:size_conv_binary_single
    C(i,32+indexa(i))=cd3(i,indexa(i));
end;


for i=1:size_conv_binary_single 
 audiomodifiedsegment(i,:)=waverec(C(i,:),L(i,:),'haar');
end;

for i=1:size_conv_binary_single
    for j=1:ElementsPerSegment
        finalaudio((i-1)*ElementsPerSegment+j)=audiomodifiedsegment(i,j);
    end;
end;
finalaudio=finalaudio';
audiowrite('DWT_OUTPUT_image.wav',finalaudio,fs);
