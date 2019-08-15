function[P] = sht(X,mic,N_harm)
%SHT returns the (uncompensated) eigenbeams given the STFT of the
%microphone signals
%

% multiply each microphone signal by it's quadrature weight
X = bsxfun(@times, X, mic.quad.');                                         % [nfreq, nchans, nframes]
% evaluate spherical harmonics at sensor angles
Y = conj(sphBasis(mic.sensor_angle(:,1), mic.sensor_angle(:,2), N_harm));  % [nchans, nbasis]
% Y = conj(sphBasis(mic(:,1), mic(:,2), N_harm));  % [nchans, nbasis]

nbasis = size(Y,2);

% perform transform
% equivalent to looping over ii and doing matrix multiply P(:,:,ii) = X(:,:,ii) * Y
[nfreq, nchans, nframes] = size(X);
P = reshape(permute(X,[1 3 2]),nfreq*nframes,nchans) * Y;                  % [nfreq*nframes, nbasis]
P = permute(reshape(P,nfreq,nframes,nbasis),[1 3 2]);                      % [nfreq, nbasis, nframes]
