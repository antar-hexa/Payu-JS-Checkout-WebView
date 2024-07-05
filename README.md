# payu-checkout-webview

payu checkout webview

## Install

```bash
npm install payu-checkout-webview
npx cap sync
```

## API

<docgen-index>

* [`echo(...)`](#echo)
* [`openWebView(...)`](#openwebview)
* [`closeWebView()`](#closewebview)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### echo(...)

```typescript
echo(options: { value: string; }) => Promise<{ value: string; }>
```

| Param         | Type                            |
| ------------- | ------------------------------- |
| **`options`** | <code>{ value: string; }</code> |

**Returns:** <code>Promise&lt;{ value: string; }&gt;</code>

--------------------


### openWebView(...)

```typescript
openWebView(options: { url: string; postData: string; callbackUrl: string; }) => Promise<void>
```

| Param         | Type                                                                 |
| ------------- | -------------------------------------------------------------------- |
| **`options`** | <code>{ url: string; postData: string; callbackUrl: string; }</code> |

--------------------


### closeWebView()

```typescript
closeWebView() => Promise<void>
```

--------------------

</docgen-api>
