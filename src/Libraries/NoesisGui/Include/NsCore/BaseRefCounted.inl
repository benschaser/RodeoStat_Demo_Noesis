////////////////////////////////////////////////////////////////////////////////////////////////////
// NoesisGUI - http://www.noesisengine.com
// Copyright (c) 2013 Noesis Technologies S.L. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////


#include <NsCore/Error.h>


namespace Noesis
{


////////////////////////////////////////////////////////////////////////////////////////////////////
inline BaseRefCounted::BaseRefCounted(): mRefCount(1)
{
}

////////////////////////////////////////////////////////////////////////////////////////////////////
inline BaseRefCounted::~BaseRefCounted()
{
    NS_CHECK([&]()
    {
        // Note that 1 is valid when the object lives is the stack or is being manually destroyed
        int32_t n = mRefCount.Load();
        NS_CHECK(n == 1 || n == 0, "Unexpected RefCount(%d) deleting object at %p", n, this);
        return true;
    }
    (), "_");
}

////////////////////////////////////////////////////////////////////////////////////////////////////
inline int32_t BaseRefCounted::AddReference() const
{
    return const_cast<BaseRefCounted*>(this)->mRefCount.IncrementAndFetch();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
inline int32_t BaseRefCounted::Release() const
{
    NS_ASSERT(mRefCount.Load() > 0);
    int32_t ref = const_cast<BaseRefCounted*>(this)->mRefCount.DecrementAndFetch();

    if (ref == 0)
    {
        return const_cast<BaseRefCounted*>(this)->OnDestroy();
    }

    return ref;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
inline int32_t BaseRefCounted::GetNumReferences() const
{
    return mRefCount.Load();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
inline int32_t BaseRefCounted::OnDestroy()
{
    delete this;
    return 0;
}

}
