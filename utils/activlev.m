function varargout=activlev(varargin)
if nargout
    varargout=cell(1,nargout);
    [varargout{:}]=v_activlev(varargin{:});
else
    v_activlev(varargin{:});
end
