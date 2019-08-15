function varargout=rfft(varargin)
%
% For calling details please see v_rfft.m 
%
if nargout
    varargout=cell(1,nargout);
    [varargout{:}]=v_rfft(varargin{:});
else
    v_rfft(varargin{:});
end
