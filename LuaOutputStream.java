package ishang.tool.luz;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

@SuppressWarnings("unchecked")
public class LuaOutputStream {
	public static final byte TYPE_NIL = (byte) -1;
	public static final byte TYPE_FALSE = (byte) 0;
	public static final byte TYPE_TRUE = (byte) 1;
	public static final byte TYPE_INT = (byte) 4;
	public static final byte TYPE_CSTR = (byte) 6;
	public static final byte TYPE_WSTR = (byte) 7;
	public static final byte TYPE_TABLE = (byte) 8;
	public static final byte TYPE_BYTES = (byte) 9;

	public ByteBuffer buff = null;

	public static final SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	
	private LuaOutputStream(){};
	
	public final static LuaOutputStream allocate(int size) {
		LuaOutputStream bout = new LuaOutputStream();
		bout.buff = ByteBuffer.allocate(size);
		bout.buff.order(ByteOrder.LITTLE_ENDIAN);
		return bout;
	}

	public final void write_nil() {
		buff.put(TYPE_NIL);
	}

	public final void write_bool(boolean v) {
		if (v)
			buff.put(TYPE_TRUE);
		else
			buff.put(TYPE_FALSE);
	}

	public final void write_int(int v) throws IOException {
		buff.put(TYPE_INT);
		ByteHelper.putInt(buff, v);
	}

	public final void write_cstr(String v) throws IOException {
		buff.put(TYPE_CSTR);
		ByteHelper.putCStr(buff, v);
	}

	public final void write_wstr(String v) throws IOException {
		buff.put(TYPE_WSTR);
		ByteHelper.putWStr(buff, v);
	}

	public void write_table(Map v) throws IOException {
		int len = v.size();
		buff.put(TYPE_TABLE); // type
		buff.putInt(len); // num
		Iterator it = v.keySet().iterator();
		while (it.hasNext()) {
			Object key = it.next();
			Object var = v.get(key);
			
			write_object(key);
			write_object(var);
		}
	}
	
	public void write_table(List v) throws IOException {
		int len = v.size();
		buff.put(TYPE_TABLE); // type
		buff.putInt(len); // num
		Integer p = 1;
		for (Object o : v) {
			Integer k = p++;
			write_object(k);
			write_object(o);
		}
	}

	public void write_int(int[] v) throws IOException {
		int len = v.length;
		buff.put(TYPE_TABLE); // type
		buff.putInt(len); // num
		Integer p = 1;
		for (Object o : v) {
			Integer k = p++;
			write_object(k);
			write_object(o);
		}
	}
	public void write_bytes(byte[] b){
		int len = b.length;
		buff.put(TYPE_BYTES);
		buff.putInt(len);
		buff.put(b);
	}
	
	public final void write_object(Object o) throws IOException {
		if (o == null){
			write_nil();
		}//else if (o instanceof Date){
			//long tm = ((Date)o).getTime();
			//write_int((int)tm);
			else if(o instanceof Date){
			 String s = sdf.format(o);
			 write_wstr(s);
		}else if (o instanceof String){
			String s = (String) o;
			if(isWStr(s)){
				write_wstr(s);
			}else{
				write_cstr(s);
			}
		}else if (o instanceof Boolean)
			write_bool(((Boolean) o).booleanValue());
		else if (o instanceof Integer)
			write_int(((Integer) o).intValue());
		else if (o instanceof Float)
			write_int(((Float) o).intValue());
		else if (o instanceof Double)
			write_int(((Double) o).intValue());
		else if (o instanceof Long)
			write_int(((Long) o).intValue());
		else if (o instanceof Map)
			write_table((Map) o);
		else if (o instanceof List)
			write_table((List) o);
		else if (o instanceof byte[])
			write_bytes((byte[]) o);
		else if (o instanceof int[])
			write_int((int[]) o);
		else{
			throw new IOException("unsupported object:"+o);
		}
	}
	
	public final byte[] toByteArray() throws IOException{
		return ByteHelper.toByteArray(buff);
	}

	public final static byte[] objectToBytes(Object o) throws IOException{
		LuaOutputStream out = LuaOutputStream.allocate(1280 * 1024);
		out.write_object(o);
		return out.toByteArray();
	}
	
	public final static byte[] mapToBytes(Map m) throws IOException{
		return objectToBytes(m);
	}
	
	public final void toFile(String file) throws IOException{
		FileOutputStream fos = new FileOutputStream(file);
		byte[] b = toByteArray();
		fos.write(b);
		fos.close();
		fos = null;
	}
	
	public static final boolean isWStr(String s){
		try {
			//boolean isw = false;
			byte[] b = s.getBytes("UTF-8");
			for (int i = 0; i < b.length; i++) {
				if (b[i] >= 127 || b[i] < 0) {
					return true; //isw = true;
					//break;
				}
			}
			//return isw;
			return false;
		} catch (Exception e) {
			return true;
		}
	}
	
	public static void main(String[] args) throws IOException{
		String file = "C:/ishang/r/r.bin";
		String file2 = "C:/ishang/r/r2.bin";
		Object m = LuaInputStream.loadFromFile(file);
//		System.out.println(m);
		LuaOutputStream out = LuaOutputStream.allocate(8096);
		out.write_object(m);
		out.toFile(file2);
	}
	
}
