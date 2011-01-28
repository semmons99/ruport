module Ruport
  module Controller
    class RequiredOptionNotSet < RuntimeError #:nodoc:
    end

    class UnknownFormatError < RuntimeError #:nodoc:
    end

    class StageAlreadyDefinedError < RuntimeError #:nodoc: 
    end

    class ControllerNotSetError < RuntimeError #:nodoc:
    end
  end
end
