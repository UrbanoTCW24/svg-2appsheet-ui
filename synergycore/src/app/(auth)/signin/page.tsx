"use client";

import { useFormState, useFormStatus } from "react-dom";
import { signInAction, type SignInState } from "./actions";

function SubmitButton() {
  const { pending } = useFormStatus();
  return (
    <button
      type="submit"
      disabled={pending}
      className="w-full h-10 rounded bg-black text-white dark:bg-white dark:text-black font-medium"
    >
      {pending ? "Ingresando..." : "Ingresar"}
    </button>
  );
}

export default function SignInPage() {
  const [state, action] = useFormState<SignInState | undefined, FormData>(signInAction, undefined);

  return (
    <div className="min-h-screen flex items-center justify-center p-6">
      <div className="w-full max-w-sm space-y-6">
        <div className="space-y-1 text-center">
          <h1 className="text-2xl font-semibold">SynergyCore</h1>
          <p className="text-sm text-gray-500">Inicia sesión para continuar</p>
        </div>
        {state?.error && (
          <div className="text-sm text-red-600" role="alert">{state.error}</div>
        )}
        <form action={action} className="space-y-4">
          <div className="space-y-1">
            <label htmlFor="email" className="text-sm font-medium">Correo</label>
            <input
              id="email"
              name="email"
              type="email"
              className="w-full h-10 px-3 rounded border border-gray-300 bg-white text-black dark:bg-black dark:text-white dark:border-gray-700"
              placeholder="tucorreo@empresa.com"
              required
            />
          </div>
          <div className="space-y-1">
            <label htmlFor="password" className="text-sm font-medium">Contraseña</label>
            <input
              id="password"
              name="password"
              type="password"
              className="w-full h-10 px-3 rounded border border-gray-300 bg-white text-black dark:bg-black dark:text-white dark:border-gray-700"
              placeholder="••••••••"
              required
            />
          </div>
          <SubmitButton />
        </form>
      </div>
    </div>
  );
}
