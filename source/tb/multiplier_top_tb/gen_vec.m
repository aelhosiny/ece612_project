
%% Generate random inputs to the multiplier and reference result

% call random function which will generate floating point numbers < 1

nsamples = 10000;

multiplicand = zeros(nsamples,1);
multiplier = zeros(nsamples,1);

for i = 1:nsamples
	multiplicand(i) = randn(1, 'double');
	multiplier(i) = randn(1, 'double');
end

multiplicand = round(multiplicand.*2^32);
multiplier = round(multiplier.*2^32);


result = multiplicand.*multiplier;

result = dec2bin(typecast(result, 'uint64'));
%  (typecast(B,'uint32'))

%  gauss_smpls =  gauss_smpls.*(gauss_smpls<=2^11) + (gauss_smpls-2^12).*(gauss_smpls>2^11);

multiplicand_x = dec2bin(typecast(multiplicand, 'uint32'));
multiplier_x = dec2bin(typecast(multiplier, 'uint32'));

dlmwrite('multiplicand.txt', multiplicand_x, '');
dlmwrite('multiplier.txt', multiplier_x, '');
dlmwrite('result.txt', result, '');


write_finish = 1