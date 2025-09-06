import { toast as sonnerToast } from "sonner";

type NotificationOptions = {
  duration?: number;
  position?: "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-center" | "bottom-center";
};

const DEFAULT_DURATION = 3000;
const DEFAULT_POSITION = "top-center";

export const notification = {
  success: (content: React.ReactNode, options?: NotificationOptions) => {
    return sonnerToast.success(content as string, {
      duration: options?.duration ?? DEFAULT_DURATION,
      position: options?.position ?? DEFAULT_POSITION,
    });
  },
  info: (content: React.ReactNode, options?: NotificationOptions) => {
    return sonnerToast.info(content as string, {
      duration: options?.duration ?? DEFAULT_DURATION,
      position: options?.position ?? DEFAULT_POSITION,
    });
  },
  warning: (content: React.ReactNode, options?: NotificationOptions) => {
    return sonnerToast.warning(content as string, {
      duration: options?.duration ?? DEFAULT_DURATION,
      position: options?.position ?? DEFAULT_POSITION,
    });
  },
  error: (content: React.ReactNode, options?: NotificationOptions) => {
    return sonnerToast.error(content as string, {
      duration: options?.duration ?? DEFAULT_DURATION,
      position: options?.position ?? DEFAULT_POSITION,
    });
  },
  loading: (content: React.ReactNode, options?: NotificationOptions) => {
    return sonnerToast.loading(content as string, {
      duration: options?.duration ?? DEFAULT_DURATION,
      position: options?.position ?? DEFAULT_POSITION,
    });
  },
  dismiss: (toastId: string) => {
    sonnerToast.dismiss(toastId);
  },
};
