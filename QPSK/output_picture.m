function de_data_pic=output_picture(qpsk_decode)

% 将已解调的矢量转换回350x350x3的uint8矩阵
qpsk_decode = reshape(qpsk_decode,980000,3);

redbint = qpsk_decode(:,1);
greenbint = qpsk_decode(:,2);
bluebint = qpsk_decode(:,3);

redbint = reshape(redbint,122500,8);
greenbint = reshape(greenbint,122500,8);
bluebint = reshape(bluebint,122500,8);

redt =bi2de(redbint);
greent = bi2de(greenbint);
bluet = bi2de(bluebint);

redt = reshape(redt,350,350);
greent = reshape(greent,350,350);
bluet = reshape(bluet,350,350);

lena1_QPSK_6(:,:,1) = redt;
lena1_QPSK_6(:,:,2) = greent;
lena1_QPSK_6(:,:,3) = bluet;

%生成最终的输出图像
de_data_pic = uint8(lena1_QPSK_6);

end