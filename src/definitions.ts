export interface PayUCheckoutWebViewPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
