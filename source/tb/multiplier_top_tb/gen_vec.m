
%% Generate random inputs to the multiplier and reference result

% call random function which will generate floating point numbers < 1

nsamples = 10000;

multiplicand = zeros(nsamples,1);
multiplier = zeros(nsamples,1);

for i = 1:nsamples
	multiplicand(i) = rand(1, 'single');
	multiplier(i) = rand(1, 'single');
end

multiplicand = round(multiplicand.*2^32);
multiplier = round(multiplier.*2^32);


% result = multiplicand.*multiplier;

% result = dec2bin(typecast(result, 'uint64'));
%  (typecast(B,'uint32'))

%  gauss_smpls =  gauss_smpls.*(gauss_smpls<=2^11) + (gauss_smpls-2^12).*(gauss_smpls>2^11);

% multiplicand_x = dec2bin(typecast(multiplicand, 'uint32'));
% multiplier_x = dec2bin(typecast(multiplier, 'uint32'));



% dlmwrite('multiplicand_mat.txt', multiplicand, '');
% dlmwrite('multiplier_mat.txt', multiplier, '');


multiplicand_x = dec2bin(multiplicand);
multiplier_x = dec2bin(multiplier);

dlmwrite('multiplicand_mat.txt', multiplicand_x, '');
dlmwrite('multiplier_mat.txt', multiplier_x, '');
% dlmwrite('result.txt', result, '');


multiplicand_c = dlmread('multiplicand_c.txt');
multiplier_c = dlmread('multiplier_c.txt');

% multiplicand_cb = dec2bin(typecast(multiplicand_c, 'uint32'));
% multiplier_cb = dec2bin(typecast(multiplier_c, 'uint32'));

multiplicand_cb = dec2bin(multiplicand_c);
multiplier_cb = dec2bin(multiplier_c);


dlmwrite('multiplicand_cb.txt', multiplicand_cb, '');
dlmwrite('multiplier_cb.txt', multiplier_cb, '');



write_finish = 1