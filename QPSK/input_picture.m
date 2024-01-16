function data_pic = input_picture(picture)

    lena1 = picture;
    % 为了表示每种颜色，创建3个不同的350x350矩阵
    red = lena1(:,:,1);
    green = lena1(:,:,2);
    blue = lena1(:,:,3);

    % 将它们转换为单列向量
    red = red(:);
    green = green(:);
    blue = blue(:);

    % 将这些向量转换为二进制；注意我们使用de2bi转换，这意味着正确的位是最显著的
    redbin = de2bi(red);
    greenbin = de2bi(green);
    bluebin = de2bi(blue);

    % redbin、greenbin和bluebin是16384x8矩阵。我们现在需要将它们转换为单列向量
    redbin = redbin(:);
    greenbin = greenbin(:);
    bluebin = bluebin(:);

    % 现在将这三个列向量连接起来，准备进行传输
    lena1bin = [redbin greenbin bluebin];
    datac_pic = lena1bin(:);
    % 将datac_pic从uint8转换为double precision，以便添加噪声
    data_pic = double(datac_pic);

end