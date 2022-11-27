type f64 = number;
type u32 = number;
type i32 = number;
type i8 = number;
type u8 = number;
type u16 = number;
type bool = boolean;

interface ImportMetaEnv {
  DEBUGGER?: boolean
}

declare namespace NodeJS {
  interface ProcessEnv{
    DEBUGGER?: "true"
  }
}
