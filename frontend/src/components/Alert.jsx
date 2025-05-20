import { ExclamationCircleIcon } from '@heroicons/react/24/outline';

export default function Alert({ type = 'info', message, onClose }) {
  const alertStyles = {
    success: 'bg-green-50 text-green-800 border-green-400',
    error: 'bg-red-50 text-red-800 border-red-400',
    warning: 'bg-yellow-50 text-yellow-800 border-yellow-400',
    info: 'bg-blue-50 text-blue-800 border-blue-400',
  };

  return (
    <div className={`p-4 mb-4 rounded-md border ${alertStyles[type]} flex items-start`}>
      {type === 'error' && (
        <ExclamationCircleIcon className="h-5 w-5 text-red-400 mr-2" aria-hidden="true" />
      )}
      <div className="flex-1">{message}</div>
      {onClose && (
        <button
          type="button"
          className="ml-auto text-gray-400 hover:text-gray-500 focus:outline-none"
          onClick={onClose}
          aria-label="Close"
        >
          <span className="sr-only">Close</span>
          <svg className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
            <path
              fillRule="evenodd"
              d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z"
              clipRule="evenodd"
            />
          </svg>
        </button>
      )}
    </div>
  );
}
